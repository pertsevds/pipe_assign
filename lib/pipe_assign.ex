# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule PipeAssign do
  @moduledoc """
  PipeAssign provides a macro for capturing intermediate values in Elixir pipe chains
  without breaking the flow or requiring separate assignment statements.

  ## Problem and Solution

  Traditional Elixir code forces you to choose between clean pipes and intermediate access:

      # Clean pipes, but no intermediate access
      final_result = data |> transform() |> process() |> finalize()

      # Intermediate access, but broken flow
      step1 = data |> transform()
      step2 = step1 |> process()
      final_result = step2 |> finalize()

  PipeAssign solves this with `assign_to/2`:

      import PipeAssign

      data
      |> transform()
      |> assign_to(step1)  # Capture without breaking flow
      |> process()
      |> assign_to(step2)
      |> finalize()
      |> assign_to(result) # Assign to result variable

  See the [README](https://hexdocs.pm/pipe_assign) for installation
  instructions, examples, benchmarking results, and detailed usage guidance.
  """

  alias PipeAssign.ErrorHandler

  @doc """
  This macro provides in-place assignments for pipes.

  The variable will be assigned the piped value and the value continues through the pipe,
  allowing you to capture intermediate results without breaking the pipe flow or requiring
  separate assignment statements.

  ## Examples

  Import the module and use `assign_to/2` in your pipes:

      iex> import PipeAssign
      iex> [1, 2, 3]
      ...> |> Enum.map(&(&1 * 2))
      ...> |> Enum.sum()
      ...> |> assign_to(result)
      12
      iex> result

  Chain multiple assignments in a single pipe:

      iex> import PipeAssign
      iex> %{name: "John", age: 30}
      ...> |> Map.put(:email, "john@example.com")
      ...> |> assign_to(with_email)
      ...> |> Map.put(:active, true)
      ...> |> assign_to(complete)
      ...> |> Map.keys()
      ...> |> length()
      ...> |> assign_to(result)
      4
      iex> result
      4
      iex> Map.get(with_email, :email)
      "john@example.com"
      iex> Map.get(complete, :active)
      true

  Works seamlessly with existing variables (no compiler warnings):

      iex> import PipeAssign
      iex> temp = nil
      iex> "hello world"
      ...> |> String.upcase()
      ...> |> assign_to(temp)
      ...> |> String.length()
      11
      iex> temp
      "HELLO WORLD"

  Use without import for occasional assignments:

      iex> [1, 2, 3, 4, 5]
      ...> |> Enum.filter(&rem(&1, 2) == 0)
      ...> |> PipeAssign.assign_to(evens)
      [2, 4]
      iex> evens
      [2, 4]
  """
  defmacro assign_to(value, var) do
    var_name = ErrorHandler.validate_and_extract_var_name(var)

    caller = __CALLER__
    var_exists = Enum.any?(Macro.Env.vars(caller), fn {name, _ctx} -> name == var_name end)

    if var_exists do
      quote do
        value = unquote(value)
        _ = unquote(var)
        unquote(var) = value
        value
      end
    else
      quote do
        value = unquote(value)
        var!(unquote(var)) = value
        value
      end
    end
  end
end
