defmodule Fyler.ExrabbitHelper do
  def send_to_queue(queue, msg, exchange \\ "") do
    amqp = Exrabbit.Utils.connect(Application.get_env(:fyler, :rabbit_settings))
    channel = Exrabbit.Utils.channel amqp
    Exrabbit.Utils.declare_queue(channel, queue, false, true)
    Exrabbit.Utils.publish(channel, exchange, queue, msg)
    Exrabbit.Utils.channel_close(channel)
    Exrabbit.Utils.disconnect(amqp)
  end
end
