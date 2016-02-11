defmodule Fyler.ControllerHelpers do
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [json: 2]

  def send_errors(conn, errors, status \\ 403) do
    conn
    |> put_status(status)
    |> json(%{errors: prepare_errors(errors)})
  end

  defp prepare_errors(error) when is_atom(error) do
    Atom.to_string(error)
  end

  defp prepare_errors(error), do: error
end
