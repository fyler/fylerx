defmodule Fyler.TaskQueueService do
  use GenServer

  ## Client API

  @doc """
  Starts the service with the given `name`.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def publish(task) do
    GenServer.cast(Fyler.TaskQueueService, {:publish, task})
  end

  def count do
    GenServer.call(Fyler.TaskQueueService, :count)
  end

  ## Server

  def init(:ok) do
    amqp = Exrabbit.Utils.connect(Application.get_env(:fyler, :rabbit_settings))
    channel = Exrabbit.Utils.channel amqp
    {:ok, %{connection: amqp, channel: channel, count: 0}}
  end

  def handle_call(:count, _from, state) do
    {:reply, state[:count], state}
  end

  def handle_cast({:publish, task}, state) when is_map(task) do
    new_state = case send_to_queue(task, state[:channel]) do
      {:error, _} -> 
        state
      _ ->
        %{state | count: (state[:count] + 1)}
    end

    {:noreply, new_state}
  end

  def terminate(_reason, state) do
    Exrabbit.Utils.channel_close(state[:channel])
    Exrabbit.Utils.disconnect(state[:connection])
    :ok
  end

  ## private funtions

  defp send_to_queue(task, channel) do
    task1 = encode_model(task)
    queue = queue_by_category(task)
    Exrabbit.Utils.declare_queue(channel, queue, false, true)
    Exrabbit.Utils.publish(channel, "", queue, encode_model(task))
    Fyler.Task.mark_as(:queued, task.id)
  end

  defp queue_by_category(task) do
    "fyler.tasks.#{task.category}"
  end

  defp encode_model(model, options) do
    Poison.encode!(model, options)
  end

  defp encode_model(model) do
    encode_model(model, [])
  end
end
