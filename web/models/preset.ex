defmodule Fyler.Preset do
  use Fyler.Web, :model

  @primary_key {:id, :string, []}
  schema "presets" do
    field :data, :map
  end

  @required_fields ~w(id data)
  @optional_fields ~w()
  @update_fields ~w(data)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:id, ~r/\w+:\w+/)
    |> unique_constraint(:id)
  end

  def update_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @update_fields)
  end

end