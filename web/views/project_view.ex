defmodule Fyler.ProjectsView do
  use Fyler.Web, :view

  import Fyler.JsonView

  @attributes [:id, :name, :api_key, :settings]

  def render("create.json", %{data: data}) do
    show_project(data)
  end

  def render("show.json", %{data: data}) do
    show_project(data)
  end

  def render("error.json", %{changeset: changeset}) do
    render_error %{changeset: changeset}
  end

  defp show_project(data) do
    %{
      project: data |> Map.take(@attributes)
     }
  end
end
