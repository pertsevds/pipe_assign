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
      # Use a more dynamic boolean to avoid type warnings
      # false
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
    test "string literal should fail with our custom error" do
      assert_raise ArgumentError, ~r/Cannot assign to string literal/, fn ->
        Code.eval_quoted(
          quote do
            import PipeAssign

            assign_to(42, "not_a_var")
          end
        )
      end
    end

    test "number literal should fail with our custom error" do
      assert_raise ArgumentError, ~r/Cannot assign to number literal/, fn ->
        Code.eval_quoted(
          quote do
            import PipeAssign

            assign_to(42, 123)
          end
        )
      end
    end

    test "atom literal should fail with our custom error" do
      assert_raise ArgumentError, ~r/Cannot assign to atom literal/, fn ->
        Code.eval_quoted(
          quote do
            import PipeAssign

            assign_to(42, :atom)
          end
        )
      end
    end

    test "complex patterns fail with our custom error for tuple" do
      assert_raise ArgumentError, ~r/Cannot assign to tuple pattern/, fn ->
        Code.eval_quoted(
          quote do
            import PipeAssign

            assign_to(42, {a, b})
          end
        )
      end
    end

    test "function calls fail with function call error" do
      assert_raise ArgumentError, ~r/Cannot assign to function call/, fn ->
        Code.eval_quoted(
          quote do
            import PipeAssign

            assign_to(42, some_function())
          end
        )
      end
    end
  end

  describe "error message quality" do
    test "error message includes the problematic code for literals" do
      error =
        assert_raise ArgumentError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(42, "string_literal")
            end
          )
        end

      assert error.message =~ "string_literal"
      assert error.message =~ "Cannot assign to string literal"
      assert error.message =~ "simple variable name"
    end

    test "error messages are helpful and descriptive" do
      error =
        assert_raise ArgumentError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(42, [1, 2, 3])
            end
          )
        end

      assert error.message =~ "Cannot assign to list literal"
      assert error.message =~ "simple variable name"
    end
  end

  describe "variable reassignment patterns" do
    test "reassigning same variable multiple times works" do
      counter = 0

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

    test "existing variable assignment works" do
      existing_var = "initial"

      result =
        "hello"
        |> String.upcase()
        |> assign_to(existing_var)
        |> String.length()

      assert result == 5
      assert existing_var == "HELLO"
    end
  end

  describe "complex pipe scenarios" do
    test "chained transformations with intermediate captures" do
      data = %{users: [%{name: "Alice", age: 30}, %{name: "Bob", age: 25}]}

      result =
        data
        |> Map.get(:users)
        |> assign_to(users_list)
        |> Enum.map(&Map.get(&1, :name))
        |> assign_to(names_list)
        |> Enum.join(", ")
        |> assign_to(joined_names)
        |> String.length()

      assert result == 10
      assert users_list == [%{name: "Alice", age: 30}, %{name: "Bob", age: 25}]
      assert names_list == ["Alice", "Bob"]
      assert joined_names == "Alice, Bob"
    end

    test "multiple data transformations with error handling" do
      input = %{data: [1, 2, 3, 4, 5]}

      result =
        input
        |> Map.get(:data, [])
        |> assign_to(raw_data)
        |> Enum.filter(&(rem(&1, 2) == 0))
        |> assign_to(evens)
        |> Enum.map(&(&1 * 2))
        |> assign_to(doubled)
        |> Enum.sum()

      assert result == 12
      assert raw_data == [1, 2, 3, 4, 5]
      assert evens == [2, 4]
      assert doubled == [4, 8]
    end
  end

  describe "macro hygiene and scoping" do
    test "assign_to doesn't interfere with local variables" do
      value = "original"
      temp = "temp"

      result =
        "new_value"
        |> String.upcase()
        |> assign_to(assigned)
        |> String.length()

      # Original variables should be unchanged
      assert value == "original"
      assert temp == "temp"
      assert assigned == "NEW_VALUE"
      assert result == 9
    end

    test "multiple assign_to calls don't interfere" do
      first = nil
      second = nil
      third = nil

      final =
        "start"
        |> String.upcase()
        |> assign_to(first)
        |> String.downcase()
        |> assign_to(second)
        |> String.capitalize()
        |> assign_to(third)
        |> String.length()

      assert final == 5
      assert first == "START"
      assert second == "start"
      assert third == "Start"
    end
  end

  describe "performance considerations" do
    test "assign_to with large data structures" do
      large_list = Enum.to_list(1..1000)

      result =
        large_list
        |> Enum.filter(&(rem(&1, 2) == 0))
        |> assign_to(evens)
        |> Enum.take(10)
        |> assign_to(first_ten)
        |> length()

      assert result == 10
      assert length(evens) == 500
      assert length(first_ten) == 10
      assert first_ten == [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
    end

    test "assign_to in loops performs adequately" do
      # Test that assign_to doesn't cause performance issues with many operations
      result =
        1..100
        |> Enum.to_list()
        |> assign_to(numbers_list)
        |> Enum.map(&(&1 * 2))
        |> assign_to(doubled_list)
        |> Enum.sum()

      # Should complete without issues
      assert length(numbers_list) == 100
      assert length(doubled_list) == 100
      assert result == 10_100
    end
  end

  describe "edge cases with existing variables" do
    test "assign_to with variables that shadow built-ins" do
      # Use a different name to avoid conflicts
      my_length = "not_the_function"

      result =
        [1, 2, 3, 4]
        |> Enum.sum()
        |> assign_to(my_length)
        |> Kernel.*(2)

      assert result == 20
      assert my_length == 10
    end

    test "assign_to with commonly named variables" do
      data = "initial"
      value = "initial"
      result = "initial"

      final =
        "test"
        |> String.upcase()
        |> assign_to(data)
        |> String.downcase()
        |> assign_to(value)
        |> String.capitalize()
        |> assign_to(result)
        |> String.length()

      assert final == 4
      assert data == "TEST"
      assert value == "test"
      assert result == "Test"
    end
  end

  describe "integration with elixir constructs" do
    test "assign_to with Enum functions" do
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

    test "assign_to with String functions" do
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

    test "assign_to with Map functions" do
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
  end

  describe "edge cases with nil and falsy values" do
    test "assign_to with nil values" do
      result =
        nil
        |> Kernel.||(42)
        |> assign_to(nil_result)
        |> Kernel.*(2)

      assert result == 84
      assert nil_result == 42
    end

    test "assign_to with false values" do
      result =
        false
        |> Kernel.or(true)
        |> assign_to(bool_result)

      assert result == true
      assert bool_result == true
    end

    test "assign_to with empty collections" do
      result =
        []
        |> Enum.concat([1, 2, 3])
        |> assign_to(concat_result)
        |> length()

      assert result == 3
      assert concat_result == [1, 2, 3]
    end
  end
end
