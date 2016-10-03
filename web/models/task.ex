defmodule Fyler.Task do
  use Fyler.Web, :model
  require IEx
  @primary_key {:id, :binary_id, read_after_writes: true}

  schema "tasks" do
    field :status, :string
    field :type, :string
    field :category, :string
    field :source, :string
    field :worker_id, :string
    field :data, :map
    field :result, :map
    field :queue_time, :integer
    field :file_size, :integer
    field :download_time, :integer
    field :process_time, :integer
    field :upload_time, :integer
    field :total_time, :integer
    field :total_task_time, :integer
    field :inserted_at, :integer, default: :os.system_time(:milli_seconds)
    
    belongs_to :project, Fyler.Project
    # timestamps
  end

  @statuses default: "idle",
            queued: "queued",
            downloading: "downloading",
            processing: "processing",
            uploading: "uploading",
            completed: "completed",
            error: "error",
            aborted: "aborted"

  @required_fields ~w(project_id source type category)
  @optional_fields ~w(data)

  @doc """
  Scopes methods
  """
  def by_status(query, nil), do: query

  def by_status(query, status) do
    query |> where([t], t.status == ^status)
  end
  
  def by_project(query, project_id) when is_integer(project_id) do
    query |> where([t], t.project_id == ^project_id)
  end

  def by_project(query, _), do: query

  def by_category(query, nil), do: query

  def by_category(query, category) do
    query |> where([t], t.category == ^category)
  end

  # sort is Keyword List like: %{field1: :asc, field2: :desc, ...}
  def with_order(query, sort) when is_map(sort) do
    filter = for {field, ord} <- sort, do: {String.to_atom(ord), String.to_atom(field)}
    query |> order_by(^filter)
  end

  def with_order(query, _), do: query

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> prepare_changes(fn(c) -> delete_change(c, :id) end)
  end

  def create_changeset(model, params \\ :empty) do
    task_params = Fyler.MapUtils.keys_to_atoms(params)

    model
    |> cast(Map.merge(task_params, build_category(task_params[:type])), @required_fields, @optional_fields)
    |> validate_format(:source, ~r/^(([a-zA-Z0-9]+\:\/\/)?[a-zA-Z0-9]+((?:(?:\.|\-)[a-zA-Z0-9]+)?)+(?:\:\d+)?(?:\/[\w\-]+)*(?:\/?|\/\w+\.[a-zA-Z0-9]{2,4}(?:\?[\w]+\=[\w\-]+)?)?(?:\&[\w]+\=[\w\-]+)*)$/)
    |> validate_inclusion(:type, types_list)
    |> put_change(:status, @statuses[:default])
    |> prepare_changes(fn(c) -> delete_change(c, :id) end)
  end

  def status_changeset(model, params \\ :empty, req_fields \\ [], opt_fields \\ []) do
    model |> cast(Fyler.MapUtils.keys_to_atoms(params), req_fields, opt_fields)
  end

  def create_and_send_to_queue(model, params \\ :empty) do
    changeset = create_changeset(model, params)
    case Repo.insert(changeset) do
      {:ok, task} ->
        send_to_queue(task)
        {:ok, task}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def send_to_queue(model) when is_map(model) do
    Fyler.TaskQueueService.publish(transform(model))
  end

  def update_status_changeset(model, params \\ :empty) do
    model
    |> cast(Fyler.MapUtils.keys_to_atoms(params), [:status], [])
    |> validate_inclusion(:status, Keyword.values(@statuses))
  end

  def transform(model) do
    %{
      id: model.id,
      name: Fyler.UrlHelper.file_name(model.source),
      extension: Fyler.UrlHelper.file_ext(model.source),
      category: model.category,
      type: model.type,
      source: transform_url(:source, model),
      output: transform_url(:output, model),
      timeout: 3600,
      options: transform_data(model)
    }
  end

  def mark_as(status, id) when is_binary(id) do
    case Repo.get_by(Fyler.Task, id: id) do
      nil -> {:error, :task_not_found}
      task -> mark_as(status, task)
    end
  end

  def mark_as(status, model) when is_atom(status) do
    changeset = update_status_changeset(model, %{status: @statuses[status]})
    Repo.update(changeset)
  end

  def change_status(data) do
    case Repo.get_by(Fyler.Task, id: data[:id]) do
      nil -> {:error, :task_not_found}
      task ->
        change_status(data, task)
    end
  end

  def change_status(data, task) do
    case data[:status] do
      "downloading" ->
        handle_downloading(data, task)
      "processing" ->
        handle_processing(data, task)
      "uploading" ->
        handle_uploading(data, task)
      "completed" ->
        handle_completed(data, task)
      "error" ->
        handle_error(data, task)
      "aborted" ->
        handle_aborted(data, task)
    end
  end

  defp handle_downloading(payload, task) do
    data = payload[:data]
    inserted_sec = task.inserted_at
    now_sec = :os.system_time(:milli_seconds)
    queue_time = now_sec - inserted_sec
    changeset = status_changeset(task, %{worker_id: data[:worker_id], status: payload[:status], queue_time: queue_time}, [:status, :worker_id, :queue_time])
    {:ok, task} = Repo.update(changeset)
  end

  defp handle_processing(payload, task) do
    data = payload[:data]
    changeset = status_changeset(task, %{file_size: data[:size], status: payload[:status], download_time: data[:download_time]}, [:status, :download_time, :file_size])    
    {:ok, task} = Repo.update(changeset)
  end

  defp handle_uploading(payload, task) do
    data = payload[:data]
    changeset = status_changeset(task, %{status: payload[:status], process_time: data[:process_time]}, [:status, :process_time])
    {:ok, task} = Repo.update(changeset)
  end

  defp handle_completed(payload, task) do
    data = payload[:data]
    changeset = status_changeset(
                  task, 
                  %{
                    status: payload[:status],
                    task_total_time: calc_task_total_time(task, data[:upload_time]),
                    total_time: calc_total_time(task, data[:upload_time])
                  },
                  [:status, :task_total_time, :total_time, :result]
                )
    {:ok, task}
  end

  defp handle_error(payload, task) do
  end

  defp handle_abort(payload, task) do
  end

  defp calc_total_time(task, upload_time) do
    task.queue_time + calc_task_total_time(task, upload_time)
  end

  defp calc_task_total_time(task, upload_time) do
    task.download_time + task.process_time + upload_time
  end

  defp handle_error(payload, task) do
  end

  defp handle_aborted(payload, task) do
  end

  defp transform_url(:source, model) do
    data = parse_url(model.source)
    
    case data[:type] do
      "s3" -> data |> Map.put(:credentials, aws_credentials(model))
      _ -> data
    end
  end

  defp transform_url(:output, model) do
    if model.data && Map.has_key?(model.data, "output") do
      data = parse_url(model.data["output"])
      if data[:type] == "s3" do
        Map.put(data, :credentials, aws_credentials(model))
      end
    else
      data = parse_url(model.source)
      items = String.split(data[:prefix], "/")
      output = data |> Map.put(:prefix, Enum.join(List.delete_at(items, length(items) - 1), "/"))
      if data[:type] == "s3", do: Map.put(output, :credentials, aws_credentials(model))
    end
  end

  defp parse_url(url) do
    out = %{}
    
    [type, path] = case String.split(url, "://") do
                     [protocol, uri] -> [protocol, uri]
                     [uri] -> [nil, uri]
                   end

    case type do
      "s3" ->
        # delete last element and join string again
        # for example s3://testbucket/folder/file.mp3
        # bucket is <testbucket>
        # prefix is <folder/file.mp3>
        [bucket | prefix] = String.split(path, "/")
        
        out
        |> Map.put(:type, type)
        |> Map.put(:bucket, bucket)
        |> Map.put(:prefix, Enum.join(prefix, "/"))
      nil ->
        Map.put(out, :prefix, path)
    end
  end

  defp aws_credentials(model) do
    project = Repo.get(Fyler.Project, model.project_id)

    %{
      aws_id: project.settings["aws_id"],
      aws_secret: project.settings["aws_secret"],
      aws_region: project.settings["aws_region"]
    }
  end

  # TODO: transform presets
  defp transform_data(model) do
    model.data
  end

  defp build_category(nil), do: %{category: nil}
  defp build_category(type) when type == "pipe", do: %{}

  defp build_category(type) do
    %{category: Atom.to_string(task_types[String.to_atom(type)])}
  end

  defp types_list do
    types_list = Keyword.keys(task_types)
    (for type <- types_list, do: Atom.to_string(type)) ++ ["pipe"]
  end

  defp task_types do
    Application.get_env(:fyler, :task_types)
  end
end
