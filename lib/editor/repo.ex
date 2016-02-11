# TODO: move this out of repo.ex
defmodule Editor.Repo do
  import Agent

  def start_link do
    Agent.start_link(fn -> "<img src='http://i.giphy.com/MMIKQNEsdmKSk.gif'>" end, name: __MODULE__)
    {:ok, self}
  end

  def _get_agent do
    Agent.get(__MODULE__, fn str -> str end)
  end

  def run(new_value) do
    Agent.update(__MODULE__, fn str -> new_value end)
  end
end
