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

  import PipeAssign

  @test_value "module_attribute"
  @numeric_attr 42
  @list_attr [1, 2, 3]

  describe "module attribute edge cases" do
    test "match to module attributes works" do
      assert match_to(42, @numeric_attr)
      assert match_to("module_attribute", @test_value)
      assert match_to([1, 2, 3], @list_attr)
    end

    # I commented this test because of incosistency between
    # 1.15-17 and 1.18 versions, where 1.15-17 throws additional warning.
    # test "module attributes cannot be used as assign_to target" do
    #   assert_raise MatchError, ~r/no match of right hand side value/, fn ->
    #     assign_to(43, @numeric_attr)
    #   end
    # end

    test "module attributes can be used as values in pipes" do
      @test_value
      |> assign_to(result)
      |> String.length()
      |> assign_to(length)

      assert length == 16
      assert result == "module_attribute"
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

  describe "macro hygiene" do
    test "variable assignment in same scope works correctly" do
      import PipeAssign

      temp_var = "outer"

      inner_result =
        if true do
          temp_var = "inner init"

          assert temp_var == "inner init"

          result =
            "inner"
            |> String.upcase()
            |> assign_to(temp_var)

          # temp_var is assigned within this scope
          assert temp_var == "INNER"
          result
        end

      # outer_var should be unchanged
      assert temp_var == "outer"
      assert inner_result == "INNER"
    end
  end

  describe "integration with other macros" do
    test "assign_to works with custom macros" do
      import PipeAssign

      alias ModuleAttributeTest.TestMacros

      require ModuleAttributeTest.TestMacros

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
          temp_value = "inner init"

          assert temp_value == "inner init"

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
end
