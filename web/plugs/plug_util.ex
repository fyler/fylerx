defmodule Fyler.Plug.Util do
  import Plug.Conn

  def token_from_conn(conn) do
    get_req_header(conn, "authorization")
    |> token_from_header
  end

  def token_from_header(["Bearer " <> token]), do: {:ok, token}
  def token_from_header(_), do: {:error, :token_not_present}
end
