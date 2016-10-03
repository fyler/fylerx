defmodule Fyler.PresetsController do
  use Fyler.Web, :controller

  alias Fyler.Preset

  def create(conn, %{"preset" => params}) do
    changeset = Preset.create_changeset(%Preset{}, params)
    
    case Repo.insert(changeset) do
      {:ok, preset} ->
        render conn, "create.json", data: preset
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render("error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    render conn, "show.json", data: Repo.get!(Preset, id)
  end

  def update(conn, %{"id" => id, "preset" => params}) do
    preset = Repo.get!(Preset, id)
    changeset = Preset.update_changeset(preset, params)

    case Repo.update(changeset) do
      {:ok, preset} ->
        render conn, "show.json", data: preset
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    preset = Repo.get!(Preset, id)
    case Repo.delete(preset) do
      {:ok, preset} ->
        render conn, "show.json", data: preset
      _ ->
        send_errors(conn, :access_denied, 403)
    end
  end
end
