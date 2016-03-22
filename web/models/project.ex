defmodule Fyler.Project do
  use Fyler.Web, :model

  schema "projects" do
    field :name, :string
    field :api_key, :string
    field :settings, :map

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(settings api_key)
  @update_fields ~w(settings)

  def count_records do
    Fyler.Repo.one(from p in Fyler.Project, select: count(p.id)) 
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def create_changeset(model, params \\ :empty) do
    model
    |> cast(Map.merge(Fyler.MapUtils.keys_to_atoms(params), %{api_key: Fyler.Token.generate}), @required_fields, @optional_fields)
    |> unique_constraint(:api_key)
  end

  def update_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @update_fields)
  end

  def refresh_changeset(model) do
    model
    |> cast(%{api_key: Fyler.Token.generate}, ["api_key"], [])
    |> unique_constraint(:api_key)
  end

  def revoke_changeset(model) do
    model
    |> cast(%{api_key: nil}, [], ["api_key"])
  end
end
