defmodule Fyler.ExUnit.AuthHelpers do
  def auth_conn(conn, user, password \\ "qwerty") do
    {:ok, token} = Fyler.Authenticator.authenticate %{"email" => user.email, "password" => password}
    conn |> Plug.Conn.put_req_header("authorization", "Bearer " <> token)
  end
end
