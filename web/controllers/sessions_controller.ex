defmodule Fyler.SessionsController do
  use Fyler.Web, :controller
  alias Fyler.Authenticator

  def create(conn, params) do
    res = Authenticator.authenticate params
    case res do
      {:error, error} -> send_errors(conn, error)
      {:ok, token} -> json conn, %{token: token}
    end
  end
end
