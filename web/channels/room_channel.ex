defmodule Chat.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias Editor.State

  def join("topic:" <> _topic_name, _auth_msg, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    result = State._get_agent
    broadcast! socket, "message", %{body: result}
    {:noreply, socket}
  end

  def handle_in("message", %{"body" => body}, socket) do
    broadcast! socket, "message", %{body: body}
    State.run(body)
    {:noreply, socket}
  end
end
