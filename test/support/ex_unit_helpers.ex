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

  # Function for waiting
  def wait_until(fun), do: wait_until(500, fun)
  def wait_until(0, fun), do: fun.()

  def wait_until(timeout, fun) do
    try do
      fun.()
    rescue
      ExUnit.AssertionError ->
        :timer.sleep(10)
        wait_until(max(0, timeout - 10), fun)
    end
  end
end
