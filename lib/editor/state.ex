defmodule Editor.State do
  import Agent
  def start_link do
    Agent.start_link(fn -> "<div>lol</div>" end, name: __MODULE__) # -> []
    {:ok, self}
  end

  def get_agent do
    Agent.get(__MODULE__, fn str -> str end)
  end

  def run(new_value) do
    Agent.update(__MODULE__, fn str -> new_value end)
  end
end
