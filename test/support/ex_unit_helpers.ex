defmodule Fyler.ExUnit.Helpers do
  def is_changed(event, changes, by: delta) when is_function(event) and is_function(changes) do
    before_value = changes.()
    event.()
    after_value = changes.()

    changed? before_value, after_value, delta
  end

  defp changed?(before_val, after_val, delta) do
    delta == (after_val - before_val)
  end
end
