# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule PipeAssign.ErrorHandler do
  @moduledoc """
  Error handling and validation logic for PipeAssign.

  This module contains all the logic for validating variable names and generating
  appropriate error messages when invalid variables are passed to `assign_to/2`.

  The error handling system categorizes different types of invalid inputs and
  provides specific, helpful error messages for each case.
  """

  @doc """
  Validates a variable AST node and extracts its name.

  Returns the variable name if valid, or raises an ArgumentError with a
  detailed message if the variable is invalid.

  ## Examples

      iex> PipeAssign.ErrorHandler.validate_and_extract_var_name({:my_var, [], nil})
      :my_var

      iex> PipeAssign.ErrorHandler.validate_and_extract_var_name("not_a_var")
      ** (ArgumentError) Cannot assign to string literal...

  """
  def validate_and_extract_var_name(var) do
    case extract_valid_var_name(var) do
      {:ok, name} -> name
      :error -> raise_invalid_var_error(var)
    end
  end

  # Extract variable name if valid, return error tuple if invalid
  defp extract_valid_var_name(var) do
    case var do
      # Simple variables like my_var - context is atom or nil, not a list
      {name, _meta, context} when is_atom(name) and (is_atom(context) or is_nil(context)) ->
        {:ok, name}

      _ ->
        :error
    end
  end

  # Generate appropriate error message based on the invalid variable type
  defp raise_invalid_var_error(var) do
    error_type = categorize_invalid_var(var)
    error_message = get_error_message(error_type, var)
    raise ArgumentError, error_message
  end

  # Categorize the type of invalid variable for better error messages
  defp categorize_invalid_var(var) do
    case categorize_ast_node(var) do
      :unknown -> categorize_literal_value(var)
      ast_type -> ast_type
    end
  end

  # Categorize AST node types (macro constructs, function calls, etc.)
  defp categorize_ast_node(var) do
    cond do
      module_attribute?(var) -> :module_attribute
      remote_function_call?(var) -> :remote_function_call
      binary_operation?(var) -> :binary_operation
      local_function_call?(var) -> :local_function_call
      true -> :unknown
    end
  end

  # Categorize literal value types
  defp categorize_literal_value(var) do
    cond do
      is_tuple(var) -> :tuple_pattern
      is_list(var) -> :list_literal
      is_binary(var) -> :string_literal
      is_number(var) -> :number_literal
      is_atom(var) -> :atom_literal
      true -> :unknown
    end
  end

  # Check if var is a module attribute like @attr
  defp module_attribute?({:@, _meta, _attr}), do: true
  defp module_attribute?(_), do: false

  # Check if var is a remote function call like Module.function()
  defp remote_function_call?({{:., _meta1, _module_and_func}, _meta2, _args}), do: true
  defp remote_function_call?(_), do: false

  # Check if var is a binary operation like a + b
  defp binary_operation?({op, _meta, _operands})
       when op in [:+, :-, :*, :/, :<>, :++, :--, :==, :!=, :<, :>, :<=, :>=, :and, :or],
       do: true

  defp binary_operation?(_), do: false

  # Check if var is a local function call like func(arg)
  defp local_function_call?({func_name, _meta, args}) when is_atom(func_name) and is_list(args), do: true
  defp local_function_call?(_), do: false

  # Generate error message based on error type
  defp get_error_message(:module_attribute, var) do
    """
    Cannot assign to module attribute `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not a module attribute.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:remote_function_call, var) do
    """
    Cannot assign to remote function call `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not a function call.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:binary_operation, var) do
    """
    Cannot assign to expression `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not an expression.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:local_function_call, var) do
    """
    Cannot assign to function call `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not a function call.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:tuple_pattern, var) do
    """
    Cannot assign to tuple pattern `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not pattern matching.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:list_literal, var) do
    """
    Cannot assign to list literal `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not a literal value.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:string_literal, var) do
    """
    Cannot assign to string literal `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not a literal value.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:number_literal, var) do
    """
    Cannot assign to number literal `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not a literal value.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:atom_literal, var) do
    """
    Cannot assign to atom literal `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name, not a literal value.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end

  defp get_error_message(:unknown, var) do
    """
    Cannot assign to `#{Macro.to_string(var)}`.
    assign_to() expects a simple variable name.

    Example: assign_to(value, my_var)  # ✓ Correct
    Not: assign_to(value, #{Macro.to_string(var)})  # ✗ Wrong
    """
  end
end
