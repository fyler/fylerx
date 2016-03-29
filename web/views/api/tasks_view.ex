defmodule Fyler.Api.TasksView do
  use Fyler.Web, :view

  import Fyler.JsonView

  @attributes ~w(id worker_id upload_time process_time total_time status category type download_time data project_id queue_time source result)a

  def render("error.json", %{changeset: changeset}) do
    render_error %{changeset: changeset}
  end

  def render("create.json", %{data: data}) do
    %{task: %{id: data.id}}
  end

  def render("show.json", %{data: data}) do
    show_task(data)
  end

  defp show_task(data) do
    %{
      task: data |> Map.take(@attributes)
     }
  end
end
