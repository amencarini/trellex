defmodule Trellex.BoardChannel do
  use Trellex.Web, :channel

  intercept ["new_msg"]

  def join("board:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (board:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("new_msg", payload, socket) do
    IO.puts "received #{inspect payload}"
    broadcast! socket, "new_msg", payload
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    IO.puts "pushing #{inspect payload}"
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
