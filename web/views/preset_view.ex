defmodule Fyler.PresetsView do
  use Fyler.Web, :view

  import Fyler.JsonView

  def render("create.json", %{data: data}) do
    show_preset(data)
  end

  def render("show.json", %{data: data}) do
    show_preset(data)
  end

  def render("error.json", %{changeset: changeset}) do
    render_error %{changeset: changeset}
  end

  defp show_preset(data) do
    %{
      preset: data
     }
  end
end
