defmodule Fyler.PageController do
  use Fyler.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
