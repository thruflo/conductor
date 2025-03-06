defmodule Conductor.DemoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Conductor.Demo` context.
  """

  @doc """
  Generate a instruction.
  """
  def instruction_fixture(attrs \\ %{}) do
    {:ok, instruction} =
      attrs
      |> Enum.into(%{
        name: "some name",
        value: "some value"
      })
      |> Conductor.Demo.create_instruction()

    instruction
  end
end
