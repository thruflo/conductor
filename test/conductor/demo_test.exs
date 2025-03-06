defmodule Conductor.DemoTest do
  use Conductor.DataCase

  alias Conductor.Demo

  describe "instructions" do
    alias Conductor.Demo.Instruction

    import Conductor.DemoFixtures

    @invalid_attrs %{name: nil, value: nil}

    test "list_instructions/0 returns all instructions" do
      instruction = instruction_fixture()
      assert Demo.list_instructions() == [instruction]
    end

    test "get_instruction!/1 returns the instruction with given id" do
      instruction = instruction_fixture()
      assert Demo.get_instruction!(instruction.id) == instruction
    end

    test "create_instruction/1 with valid data creates a instruction" do
      valid_attrs = %{name: "some name", value: "some value"}

      assert {:ok, %Instruction{} = instruction} = Demo.create_instruction(valid_attrs)
      assert instruction.value == "some value"
    end

    test "create_instruction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Demo.create_instruction(@invalid_attrs)
    end

    test "update_instruction/2 with valid data updates the instruction" do
      instruction = instruction_fixture()
      update_attrs = %{value: "some updated value"}

      assert {:ok, %Instruction{} = instruction} =
               Demo.update_instruction(instruction, update_attrs)

      assert instruction.value == "some updated value"
    end

    test "update_instruction/2 with invalid data returns error changeset" do
      instruction = instruction_fixture()
      assert {:error, %Ecto.Changeset{}} = Demo.update_instruction(instruction, @invalid_attrs)
      assert instruction == Demo.get_instruction!(instruction.id)
    end

    test "delete_instruction/1 deletes the instruction" do
      instruction = instruction_fixture()
      assert {:ok, %Instruction{}} = Demo.delete_instruction(instruction)
      assert_raise Ecto.NoResultsError, fn -> Demo.get_instruction!(instruction.id) end
    end

    test "change_instruction/1 returns a instruction changeset" do
      instruction = instruction_fixture()
      assert %Ecto.Changeset{} = Demo.change_instruction(instruction)
    end
  end
end
