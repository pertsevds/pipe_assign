# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule PipeAssignTest do
  use ExUnit.Case

  import PipeAssign

  doctest PipeAssign

  test "assign_to with new variable" do
    result =
      [1, 2, 3]
      |> Enum.map(&(&1 * 2))
      |> assign_to(doubled)
      |> Enum.sum()

    assert result == 12
    assert doubled == [2, 4, 6]
  end

  test "assign_to with existing variable" do
    existing_var = "initial"

    result =
      "hello"
      |> String.upcase()
      |> assign_to(existing_var)
      |> String.length()

    assert result == 5
    assert existing_var == "HELLO"
  end

  test "assign_to with invalid variable name raises ArgumentError" do
    assert_raise ArgumentError, ~r/Cannot assign to string literal/, fn ->
      Code.eval_quoted(
        quote do
          import PipeAssign

          assign_to("test", "not_a_var")
        end
      )
    end
  end

  test "assign_to returns the piped value" do
    input = %{a: 1, b: 2}

    result =
      input
      |> Map.put(:c, 3)
      |> assign_to(intermediate)
      |> Map.keys()
      |> Enum.sort()

    assert result == [:a, :b, :c]
    assert intermediate == %{a: 1, b: 2, c: 3}
  end

  test "multiple assign_to calls in same pipe" do
    result =
      1..5
      |> Enum.to_list()
      |> assign_to(original)
      |> Enum.filter(&(rem(&1, 2) == 0))
      |> assign_to(evens)
      |> Enum.sum()

    assert result == 6
    assert original == [1, 2, 3, 4, 5]
    assert evens == [2, 4]
  end

  test "assign_to with with bare atom raises ArgumentError" do
    # Test the bare atom case by manually constructing the macro call
    # This creates a scenario where a bare atom is passed to the macro
    ast =
      quote do
        import PipeAssign

        PipeAssign.assign_to(42, unquote(:test_var))
      end

    # This should trigger the bare atom case during macro expansion
    # We expect this to fail at runtime but succeed at compile time for coverage
    assert_raise ArgumentError, ~r/Cannot assign to atom literal/, fn ->
      Code.eval_quoted(ast)
    end
  end
end
