defmodule Fyler.SessionsController do
  use Fyler.Web, :controller

  def create(conn, _params) do
    json conn, %{status: "noop"}
  end

  def delete(conn, _params) do
    json conn, %{status: "noop"}
  end
end
