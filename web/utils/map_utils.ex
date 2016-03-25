defmodule Fyler.MapUtils do
  def keys_to_atoms(map) when is_map(map) do
    for {key, val} <- map, into: %{}, do: (if is_atom(key), do: {key, val}, else: {String.to_atom(key), val})
  end

  def keys_to_atoms(_) do
    raise ArgumentError, message: 'argument should be a map'
  end
end
