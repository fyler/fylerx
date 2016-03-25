defmodule Fyler.Task do
  use Fyler.Web, :model

  @primary_key {:id, :binary_id, read_after_writes: true}
  @foreign_key_type :binary_id
  
  schema "tasks" do
    field :status, :string
    field :type, :string
    field :category, :string
    field :source, :string
    field :worker_id, :string
    field :data, :map
    field :result, :map
    field :queue_time, :integer
    field :download_time, :integer
    field :process_time, :integer
    field :upload_time, :integer
    field :total_time, :integer
    timestamps
  end

  @required_fields ~w(source type category)
  @optional_fields ~w(data)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def create_changeset(model, params \\ :empty) do
    task_params = Fyler.MapUtils.keys_to_atoms(params)
    model
    |> cast(Map.merge(task_params, build_category(task_params[:type])), @required_fields, @optional_fields)
    |> validate_format(:source, ~r/^(([a-zA-Z0-9]+\:\/\/)?[a-zA-Z0-9]+(?:(?:\.|\-)[a-zA-Z0-9]+)+(?:\:\d+)?(?:\/[\w\-]+)*(?:\/?|\/\w+\.[a-zA-Z]{2,4}(?:\?[\w]+\=[\w\-]+)?)?(?:\&[\w]+\=[\w\-]+)*)$/)
    |> validate_inclusion(:type, types_list)
    |> remove_id
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

  defp remove_id(changeset) do
    delete_change(changeset, :id)
  end
end
