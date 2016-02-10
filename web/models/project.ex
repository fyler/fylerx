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

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
