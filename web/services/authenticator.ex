defmodule Fyler.Authenticator do
  import Joken

  alias PhoenixTokenAuth.Util
  alias Fyler.User

  @doc """
  Tries to authenticate a user with the given params.

  Returns:
  * {:ok, token} if the user is found. The token has to be send in the "authorization" header on following requests: "Authorization: Bearer \#{token}"
  * {:error, message} if the user was not found
  """
  def authenticate(%{ email: email } = params) do
    user = User.from_email(email)
    changeset = User.login_changeset(user, params)

    if changeset.valid? do
      {:ok, generate_token_for(user)}
    else
      {:error, :invalid_credentials}
    end
  end

  def authenticate(_), do: {:error, :invalid_credentials}

  def verify(token_) do
    result = token(token_)
             |> verify(signer)
    if result.error do
      {:error, :invalid_token}
    else
      {:ok, result.claims}
    end
  end

  @doc """
  Returns {:ok, token}, where "token" is an authentication token for the user.
  This token encapsulates the users id and is valid for the number of minutes configured in
  ":fyler, :token_ttl"
  """
  def generate_token_for(user) do
    Map.take(user, [:id])
    |> token
    |> with_exp(current_time + token_ttl * 60)
    |> sign(signer)
    |> get_compact
  end

  defp signer do
    hs256(Application.get_env(:joken, :secret_key))
  end

  defp token_ttl do
    Application.get_env(:fyler, :token_ttl, 60)
  end
end
