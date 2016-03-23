defmodule Fyler.ErrorView do
  use Fyler.Web, :view

  def render("404.json", _assigns) do
    %{errors: %{message: "Not Found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{message: "Server Error"}}
  end
end
