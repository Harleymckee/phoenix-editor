defmodule Editor.Repo do
  # use Ecto.Repo, otp_app: :editor
  def start_link do
    Agent.start_link(fn -> "" end, name: __MODULE__)
    {:ok, self}
  end

  def _get_agent do
    "lol"
    #{:noreply, "lol"} #Agent.get(__MODULE__, fn str -> str end)
  end

  def run(str) do
    Agent.update(__MODULE__, fn str -> str end)
  end
end
