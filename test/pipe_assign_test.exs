# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule PipeAssignTest do
  use ExUnit.Case

  import PipeAssign

  doctest PipeAssign

  test "assign_to with nonexisting variable creates it" do
    result =
      [1, 2, 3]
      |> Enum.map(&(&1 * 2))
      |> assign_to(doubled)
      |> Enum.sum()

    assert result == 12
    assert doubled == [2, 4, 6]
  end

  test "assign_to with existing unused variable produces expected compilation warning" do
    ast =
      quote do
        import PipeAssign

        existing_var = "initial"

        result =
          "hello"
          |> String.upcase()
          |> assign_to(existing_var)
          |> String.length()
      end

    code = Macro.to_string(ast)

    warnings =
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Code.compile_string(code)
      end)

    assert String.contains?(warnings, ~s(variable "existing_var" is unused))
    assert String.contains?(warnings, "if the variable is not meant to be used, prefix it with an underscore")
  end

  test "the warning can be suppressed with underscore prefix" do
    ast =
      quote do
        import PipeAssign

        _existing_var = "initial"

        result =
          "hello"
          |> String.upcase()
          |> assign_to(existing_var)
          |> String.length()
      end

    code = Macro.to_string(ast)

    warnings =
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Code.compile_string(code)
      end)

    refute String.contains?(warnings, ~s(variable "_existing_var" is unused))
  end

  test "when variable does not exist before assign_to, it does not produce 'variable is unused' warning" do
    ast =
      quote do
        import PipeAssign

        result =
          "hello"
          |> String.upcase()
          |> assign_to(existing_var)
          |> String.length()
      end

    code = Macro.to_string(ast)

    warnings =
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Code.compile_string(code)
      end)

    refute String.contains?(warnings, ~s(variable "_existing_var" is unused))
  end
end
