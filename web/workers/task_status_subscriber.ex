defmodule Fyler.TaskStatusSubscriber do
  use GenServer
  import Exrabbit.Utils
  require IEx
  require Logger

  def count do
    GenServer.call(Fyler.TaskQueueService, :count)
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    queue = "fyler.task.status"
    amqp = connect(Application.get_env(:fyler, :rabbit_settings))
    channel = channel amqp
    set_qos(channel)

    declare_queue(channel, queue, false, true)
    subscribe channel, queue

    {:ok, %{connection: amqp, channel: channel, count: 0}}
  end

  def handle_call(:count, _from, state) do
    {:reply, state[:count], state}
  end

  def handle_info(request, state) do
    case parse_message(request) do
      nil ->
        Logger.info("[TaskStatusSubscriber] Nil message received;")
      {tag, payload, _} ->
        ack state[:channel], tag
        handle_payload(payload)
    end
    IO.inspect %{state | count: (state[:count] + 1)}
    {:noreply, %{state | count: (state[:count] + 1)}}
  end

  def terminate(_reason, state) do
    Exrabbit.Utils.channel_close(state[:channel])
    Exrabbit.Utils.disconnect(state[:connection])
    :ok
  end

  defp handle_payload(payload) do
    parsed = Poison.Parser.parse!(payload, keys: :atoms!)
    Fyler.Task.change_status(parsed)
  end
end
