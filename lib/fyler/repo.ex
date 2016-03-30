defmodule Fyler.Repo do
  use Ecto.Repo, otp_app: :fyler
  use Scrivener, page_size: 20
end
