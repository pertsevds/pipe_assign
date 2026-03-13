# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule EdgeCasesTest do
  @moduledoc """
  Tests for edge cases and boundary conditions with PipeAssign.

  This module tests realistic edge cases including:
  - Variable naming edge cases
  - Error conditions and messages
  - Integration with other Elixir constructs
  - Performance considerations
  """

  use ExUnit.Case

  import PipeAssign

  describe "variable naming edge cases" do
    test "variables with numbers and underscores work" do
      result =
        "test"
        |> String.upcase()
        |> assign_to(var_123)
        |> String.length()

      assert result == 4
      assert var_123 == "TEST"
    end

    test "camelCase variable works" do
      result =
        %{a: 1}
        |> Map.put(:b, 2)
        |> assign_to(camelCaseVar)
        |> map_size()

      assert result == 2
      assert camelCaseVar == %{a: 1, b: 2}
    end

    test "variables with question marks work" do
      input = String.contains?("test", "x")

      result =
        input
        |> Kernel.or(true)
        |> assign_to(boolean?)

      assert result == true
      assert boolean? == true
    end

    test "variables with exclamation marks work" do
      result =
        "test"
        |> String.upcase()
        |> assign_to(result!)
        |> String.length()

      assert result == 4
      assert result! == "TEST"
    end

    test "very long variable names work" do
      result =
        [1, 2, 3]
        |> Enum.sum()
        |> assign_to(this_is_a_very_long_variable_name_that_should_still_work_fine)

      assert result == 6
      assert this_is_a_very_long_variable_name_that_should_still_work_fine == 6
    end
  end

  describe "invalid variable patterns" do
    test "assign_to integer fail" do
      error =
        assert_raise MatchError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(42, 123)
            end
          )
        end

      assert error.term == 42
    end

    test "assign_to float fail" do
      error =
        assert_raise MatchError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(1.0, 2.0)
            end
          )
        end

      assert error.term == 1.0
    end

    test "assign_to boolean fail" do
      error =
        assert_raise MatchError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(true, false)
            end
          )
        end

      assert error.term == true
    end

    test "assign_to atom fail" do
      error =
        assert_raise MatchError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(:atom, :atom_too)
            end
          )
        end

      assert error.term == :atom
    end

    test "assign_to string fail" do
      error =
        assert_raise MatchError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to("string", "string_too")
            end
          )
        end

      assert error.term == "string"
    end

    test "assign_to list fail" do
      error =
        assert_raise MatchError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to([], [1, 2, 3])
            end
          )
        end

      assert error.term == []
    end

    test "assign_to tuple fail" do
      error =
        assert_raise MatchError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to({}, {1, 2, 3})
            end
          )
        end

      assert error.term == {}
    end

    test "assign_to map fail" do
      error =
        assert_raise MatchError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(%{}, %{a: 1, b: 2, c: 3})
            end
          )
        end

      assert error.term == %{}
    end
  end

  describe "variable reassignment patterns" do
    test "reassigning same variable multiple times works" do
      new_counter = [1, 2] |> length() |> assign_to(counter)
      assert new_counter == 2
      assert counter == 2

      new_counter = [1, 2, 3] |> length() |> assign_to(counter)
      assert new_counter == 3
      assert counter == 3

      new_counter = [1, 2, 3, 4] |> length() |> assign_to(counter)
      assert new_counter == 4
      assert counter == 4
    end
  end

  describe "assign with Elixir constructs" do
    test "assign_to with numbers" do
      assign_to(123, int)
      assign_to(1.23, float)
      assert int == 123
      assert float == 1.23
    end

    test "assign_to with true" do
      result =
        true
        |> Kernel.or(false)
        |> assign_to(bool_result)
        |> Kernel.or(false)

      assert result == true
      assert bool_result == true
    end

    test "assign_to with false" do
      result =
        false
        |> Kernel.and(true)
        |> assign_to(bool_result)
        |> Kernel.or(false)

      assert result == false
      assert bool_result == false
    end

    test "assign_to with atom" do
      result = assign_to(:my_atom, concat_result)

      assert result == :my_atom
      assert concat_result == :my_atom
    end

    test "assign_to with String" do
      text = "hello world"

      result =
        text
        |> String.upcase()
        |> assign_to(upper)
        |> String.replace(" ", "_")
        |> assign_to(with_underscore)
        |> String.length()

      assert result == 11
      assert upper == "HELLO WORLD"
      assert with_underscore == "HELLO_WORLD"
    end

    test "assign_to with List" do
      numbers = [1, 2, 3, 4, 5]

      result =
        numbers
        |> Enum.map(&(&1 * 2))
        |> assign_to(doubled)
        |> Enum.filter(&(&1 > 5))
        |> assign_to(filtered)
        |> Enum.sum()

      assert result == 24
      assert doubled == [2, 4, 6, 8, 10]
      assert filtered == [6, 8, 10]
    end

    test "assign_to with Tuple" do
      assign_to({1, 2, 3, "text"}, tuple)
      assert tuple == {1, 2, 3, "text"}
    end

    test "assign_to with Map" do
      initial_map = %{a: 1}

      result =
        initial_map
        |> Map.put(:b, 2)
        |> assign_to(with_b)
        |> Map.put(:c, 3)
        |> assign_to(with_c)
        |> Map.keys()
        |> length()

      assert result == 3
      assert with_b == %{a: 1, b: 2}
      assert with_c == %{a: 1, b: 2, c: 3}
    end

    test "assign_to with nil" do
      result = assign_to(nil, nil_result)

      assert result == nil
      assert nil_result == nil
    end

    test "assign_to with empty list" do
      result = assign_to([], concat_result)

      assert result == []
      assert concat_result == []
    end
  end
end
