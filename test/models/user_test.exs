defmodule Fyler.UserTest do
  use Fyler.ModelCase

  alias Fyler.User
  alias Fyler.Repo

  @valid_create_attrs %{name: "John", email: "john@fyler.io", password: "qwerty"}

  test "#create_changeset with valid attributes" do
    changeset = User.create_changeset(%User{}, @valid_create_attrs)
    assert changeset.valid?
  end

  test "#create_changeset invalid" do
    changeset = User.create_changeset(%User{}, %{})
    refute changeset.valid?
  end

  test "#create_changeset email is incorrect" do
    attrs = %{ @valid_create_attrs | email: "bla-bla" }
    assert {:email, "has invalid format"} in errors_on(%User{}, attrs, :create_changeset)
  end

  test "#create_changeset email is taken" do
    create(:user, email: "john@fyler.io")
    { :error, changeset } = Repo.insert(User.create_changeset(%User{}, @valid_create_attrs))
    assert {:email, "has already been taken"} in changeset.errors
  end

  test "#login_changeset is valid" do
    # we cannot use factory here, cause it is not aware of our changesets
    user = Repo.insert!(User.create_changeset(%User{}, @valid_create_attrs))
    changeset = User.login_changeset(user, @valid_create_attrs)
    assert changeset.valid?
  end

  test "#login_changeset password is incorrect" do
    create(:user)
    attrs = %{ @valid_create_attrs | password: "bla-bla" }
    assert {:password, "is incorrect"} in errors_on(%User{}, attrs, :login_changeset)
  end
end
