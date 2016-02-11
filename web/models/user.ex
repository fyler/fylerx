defmodule Fyler.User do
  use Fyler.Web, :model

  alias Fyler.Repo
  alias Fyler.User

  schema "users" do
    field :name, :string
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :authentication_tokens, {:array, :string}, default: []
    timestamps
  end

  def from_email(nil), do: { :error, :not_found }
  def from_email(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name email password), ~w())
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email, name: :index_users_on_email)
    |> maybe_update_password
  end

  def login_changeset(nil, _), do: %User{} |> cast(%{}, ~w(email password), ~w())

  def login_changeset(model, params) do
    model
    |> cast(params, ~w(email password), ~w())
    |> validate_password
  end

  def valid_password?(nil, _), do: false
  def valid_password?(_, nil), do: false
  def valid_password?(password, crypted), do: Comeonin.Bcrypt.checkpw(password, crypted)

  defp maybe_update_password(changeset) do
    case Ecto.Changeset.fetch_change(changeset, :password) do
      { :ok, password } ->
        changeset
        |> Ecto.Changeset.put_change(:encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      :error -> changeset
    end
  end

  defp validate_password(changeset) do
    case Ecto.Changeset.get_field(changeset, :encrypted_password) do
      nil -> password_incorrect_error(changeset)
      crypted -> validate_password(changeset, crypted)
    end
  end

  defp validate_password(changeset, crypted) do
    password = Ecto.Changeset.get_field(changeset, :password)
    if valid_password?(password, crypted), do: changeset, else: password_incorrect_error(changeset)
  end

  defp password_incorrect_error(changeset), do: Ecto.Changeset.add_error(changeset, :password, "is incorrect")
end
