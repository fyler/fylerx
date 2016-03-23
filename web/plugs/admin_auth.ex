defmodule Fyler.Plugs.AdminAuth do
  import Fyler.ControllerHelpers
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case check_token(conn) do
      {:ok, data} -> assign(conn, :current_user_id, data["id"])
      {:error, message} -> send_errors(conn, message) |> halt
    end
  end

  defp check_token(conn) do
    case token_from_conn(conn) do
      {:ok, token} -> auth_with_token(token)
      _ -> {:error, :bad_token}
    end
  end

  defp auth_with_token(token) do
    Fyler.Authenticator.verify(token)
  end

  defp token_from_conn(conn) do
    get_req_header(conn, "authorization")
    |> token_from_header
  end

  defp token_from_header(["Bearer " <> token]), do: {:ok, token}
  defp token_from_header(_), do: {:error, :token_not_present}
end
