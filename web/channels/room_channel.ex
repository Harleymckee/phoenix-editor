defmodule Chat.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias Editor.Repo

  def join("topic:" <> _topic_name, _auth_msg, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    result = Repo._get_agent
    #IO.puts result
    broadcast! socket, "message", %{body: result}
    #(result, fn message -> push socket, "message", message end)
    #push socket, "message", Repo._get_agent
    {:noreply, socket}
  end

  def handle_in("message", %{"body" => body}, socket) do
    broadcast! socket, "message", %{body: body}
    Repo.run(body)
    {:noreply, socket}
  end
end
