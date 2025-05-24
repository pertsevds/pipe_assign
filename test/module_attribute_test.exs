# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule ModuleAttributeTest.TestMacros do
  @moduledoc false
  defmacro double(x) do
    quote do: unquote(x) * 2
  end
end

defmodule ModuleAttributeTest do
  @moduledoc """
  Tests for module attribute interactions and compile-time edge cases with PipeAssign.

  This module tests scenarios that require module-level compilation testing,
  including module attributes, compile-time constants, and module-scoped variables.
  """

  use ExUnit.Case

  # Define some module attributes for testing
  @test_value "module_attribute"
  @numeric_attr 42
  @list_attr [1, 2, 3]

  describe "module attribute edge cases" do
    test "module attributes cannot be used as assign_to target" do
      # This should fail at compile time, but we test the error message
      assert_raise ArgumentError, ~r/Cannot assign to module attribute/, fn ->
        Code.eval_quoted(
          quote do
            import PipeAssign

            assign_to(42, @test_attr)
          end
        )
      end
    end

    test "module attributes can be used as values in pipes" do
      import PipeAssign

      result =
        @test_value
        |> String.upcase()
        |> assign_to(uppercased)
        |> String.length()

      assert result == 16
      assert uppercased == "MODULE_ATTRIBUTE"
    end

    test "numeric module attributes work in pipes" do
      import PipeAssign

      result =
        @numeric_attr
        |> Kernel.*(2)
        |> assign_to(doubled)
        |> Kernel.+(1)

      assert result == 85
      assert doubled == 84
    end

    test "list module attributes work in pipes" do
      import PipeAssign

      result =
        @list_attr
        |> Enum.map(&(&1 * 2))
        |> assign_to(doubled_list)
        |> Enum.sum()

      assert result == 12
      assert doubled_list == [2, 4, 6]
    end
  end

  describe "compile-time constant handling" do
    test "assign_to with compile-time constants" do
      import PipeAssign

      # Test with various compile-time constants
      result1 = :atom_constant |> to_string() |> assign_to(atom_str)
      assert result1 == "atom_constant"
      assert atom_str == "atom_constant"

      result2 = 123 |> Kernel.*(2) |> assign_to(number_result)
      assert result2 == 246
      assert number_result == 246

      result3 = "string_constant" |> String.upcase() |> assign_to(string_result)
      assert result3 == "STRING_CONSTANT"
      assert string_result == "STRING_CONSTANT"
    end

    test "assign_to preserves compile-time optimizations" do
      import PipeAssign

      # These should be optimized at compile time
      result =
        (1 + 2 + 3)
        |> assign_to(compile_sum)
        |> Kernel.*(2)

      assert result == 12
      assert compile_sum == 6
    end
  end

  describe "variable naming edge cases" do
    test "variables with question marks work" do
      import PipeAssign

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
      import PipeAssign

      result =
        "test"
        |> String.upcase()
        |> assign_to(result!)
        |> String.length()

      assert result == 4
      assert result! == "TEST"
    end

    test "very long variable names work" do
      import PipeAssign

      result =
        [1, 2, 3]
        |> Enum.sum()
        |> assign_to(this_is_a_very_long_variable_name_that_should_still_work_fine)

      assert result == 6
      assert this_is_a_very_long_variable_name_that_should_still_work_fine == 6
    end
  end

  describe "macro hygiene" do
    test "assign_to doesn't interfere with local variables" do
      import PipeAssign

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

    test "variable assignment in same scope works correctly" do
      import PipeAssign

      outer_var = "outer"

      inner_result =
        if true do
          temp_var = nil

          result =
            "inner"
            |> String.upcase()
            |> assign_to(temp_var)

          # temp_var is assigned within this scope
          assert temp_var == "INNER"
          result
        end

      # outer_var should be unchanged
      assert outer_var == "outer"
      assert inner_result == "INNER"
    end
  end

  describe "error scenarios" do
    test "helpful error for complex expressions" do
      error =
        assert_raise ArgumentError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(42, a + b)
            end
          )
        end

      assert error.message =~ "a + b"
      assert error.message =~ "Cannot assign to expression"
    end

    test "helpful error for remote calls" do
      error =
        assert_raise ArgumentError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(42, Module.function())
            end
          )
        end

      assert error.message =~ "Module.function()"
      assert error.message =~ "Cannot assign to remote function call"
    end

    test "helpful error for local calls" do
      error =
        assert_raise ArgumentError, fn ->
          Code.eval_quoted(
            quote do
              import PipeAssign

              assign_to(42, local_function(arg))
            end
          )
        end

      assert error.message =~ "local_function(arg)"
      assert error.message =~ "Cannot assign to function call"
    end
  end

  describe "integration with other macros" do
    test "assign_to works with custom macros" do
      import PipeAssign

      alias ModuleAttributeTest.TestMacros

      require ModuleAttributeTest.TestMacros

      doubled = nil

      result =
        5
        |> TestMacros.double()
        |> assign_to(doubled)
        |> Kernel.+(1)

      assert result == 11
      assert doubled == 10
    end

    test "assign_to in with statements works correctly" do
      import PipeAssign

      {result, value} =
        with {:ok, value} <- {:ok, "test"} do
          temp_value = nil

          length_result =
            value
            |> String.upcase()
            |> assign_to(temp_value)
            |> String.length()

          {length_result, temp_value}
        end

      assert result == 4
      assert value == "TEST"
    end
  end

  describe "performance and optimization" do
    test "assign_to doesn't create unnecessary intermediate variables" do
      import PipeAssign

      # This test ensures the macro expansion is efficient with many operations
      result =
        1..100
        |> Enum.to_list()
        |> assign_to(numbers)
        |> Enum.map(&(&1 * 2))
        |> assign_to(doubled)
        |> Enum.sum()

      # Should complete without issues
      assert length(numbers) == 100
      assert length(doubled) == 100
      assert result == 10_100
    end
  end
end
