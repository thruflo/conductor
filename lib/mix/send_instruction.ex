defmodule Mix.Tasks.SendInstruction do
  use Mix.Task
  alias Conductor.Demo

  def run([name, value]) do
    [:postgrex, :ecto]
    |> Enum.each(&Application.ensure_all_started/1)

    Conductor.Repo.start_link()

    {:ok, _} = Demo.create_instruction(%{name: name, value: value})
  end
end
