defmodule Fyler.Endpoint do
  use Phoenix.Endpoint, otp_app: :fyler

  socket "/ws", Fyler.UserSocket

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.Head
  plug Fyler.Router
end
