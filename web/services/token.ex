defmodule Fyler.Token do
  import Joken
  
  def generate do
    token
    |> with_signer(hs256(random_string))
    |> sign
    |> get_compact
  end

  defp random_string(n \\ 10) do
    :crypto.strong_rand_bytes(n)
    |> :base64.encode_to_string
    |> to_string
  end
end
