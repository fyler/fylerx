defmodule Fyler.Plugs.ProjectAuth do
  import Fyler.ControllerHelpers
  import Fyler.Plug.Util
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case check_project(conn) do
      {:ok, project} -> assign(conn, :current_project_id, project.id)
      {:error, message} -> send_errors(conn, message) |> halt
    end
  end

  defp check_project(conn) do
    case token_from_conn(conn) do
      {:ok, token} -> 
        case auth_with_token(token) do
          nil -> {:error, :project_not_found}
          project ->
            {:ok, project}
        end
      
      _ -> {:error, :bad_token}
    end
  end

  defp auth_with_token(token) do
    Fyler.Repo.get_by(Fyler.Project, api_key: token)
  end
end
