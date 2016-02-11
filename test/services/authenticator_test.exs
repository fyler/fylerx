defmodule Fyler.AuthenticatorTest do
  use Fyler.ModelCase

  alias Fyler.Authenticator

  test "#authenticate returns {ok, token} with valid credentials" do
    user = create(:user)
    assert {:ok, _} = Authenticator.authenticate(%{ "email" => user.email, "password" => "qwerty" })
  end

  test "#authenticate returns error with wrong credentials" do
    user = create(:user)
    assert {:error, :invalid_credentials} = Authenticator.authenticate(%{ "email" => user.email })
  end

  test "#authenticate returns error with wrong email" do
    assert {:error, :invalid_credentials} = Authenticator.authenticate(%{ "email" => build(:user).email })
  end

  test "#authenticate returns error with empty credentials" do
    assert {:error, :invalid_credentials} = Authenticator.authenticate(%{})
  end

  test "#verify valid token" do
    user = create(:user)
    assert {:ok, token} = Authenticator.authenticate(%{ "email" => user.email, "password" => "qwerty" })

    assert {:ok, claims} = Authenticator.verify(token)
    id = user.id
    assert %{ "id" => ^id } = claims
  end

  test "#verify invalid token" do
    assert {:error, :invalid_token} = Authenticator.verify("123456789")
  end
end
