# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule PipeAssign.Benchmarks do
  @moduledoc """
  Benchmark suite for PipeAssign performance testing.

  This module contains all the benchmark logic for comparing `assign_to/2` performance
  against traditional assignment patterns across various scenarios.

  ## Benchmark Categories

  - **Hot Path**: Performance-critical scenarios with simple operations
  - **Complex**: Multi-step pipeline transformations
  - **String**: String processing operations
  - **List**: List manipulation and processing
  - **Map**: Map operations and transformations

  ## Test Environment

  All benchmark results are based on testing performed on:
  - **Hardware**: MacBook Air M1 16GB RAM
  - **Operating System**: macOS
  - **Elixir Version**: 1.18.3
  - **Erlang/OTP Version**: 27.3.3
  """

  if Code.ensure_loaded?(Benchee) do
    import PipeAssign

    alias Benchee.Formatters.Console

    @doc """
    Run a quick comparison benchmark between assign_to and traditional assignment.
    """
    def run_quick_comparison do
      data = [1, 2, 3, 4, 5]

      Benchee.run(
        %{
          "Traditional Assignment" => fn ->
            step1 = Enum.map(data, &(&1 * 2))
            step2 = Enum.filter(step1, &(rem(&1, 2) == 0))
            result = Enum.sum(step2)
            {result, length(step1), length(step2)}
          end,
          "With assign_to/2" => fn ->
            result =
              data
              |> Enum.map(&(&1 * 2))
              |> assign_to(step1)
              |> Enum.filter(&(rem(&1, 2) == 0))
              |> assign_to(step2)
              |> Enum.sum()

            {result, length(step1), length(step2)}
          end
        },
        formatters: [{Console, comparison: true}]
      )
    end

    @doc """
    Run hot path benchmarks focusing on performance-critical scenarios.
    """
    def run_hotpath_benchmark do
      data = Enum.to_list(1..100)

      Benchee.run(
        %{
          "Hot Path Traditional" => fn ->
            result = length(data)
            step2 = result * 3
            step3 = step2 + 10
            step4 = step3 / 2
            final = round(step4)

            {final, result, step2, step3, step4}
          end,
          "Hot Path assign_to/2" => fn ->
            final =
              data
              |> length()
              |> assign_to(result)
              |> Kernel.*(3)
              |> assign_to(step2)
              |> Kernel.+(10)
              |> assign_to(step3)
              |> Kernel./(2)
              |> assign_to(step4)
              |> round()

            {final, result, step2, step3, step4}
          end
        },
        formatters: [{Console, comparison: true}]
      )
    end

    @doc """
    Run complex pipeline benchmarks with multi-step transformations.
    """
    def run_complex_benchmark do
      data = Enum.to_list(1..1000)

      Benchee.run(
        %{
          "Complex Traditional" => fn ->
            step1 = Enum.map(data, &(&1 * 3))
            step2 = Enum.filter(step1, &(&1 > 50))
            step3 = Enum.chunk_every(step2, 10)
            step4 = Enum.map(step3, &Enum.sum/1)
            step5 = Enum.sort(step4, :desc)
            result = Enum.take(step5, 5)

            {result, length(step1), length(step2), length(step3), length(step4), length(step5)}
          end,
          "Complex assign_to/2" => fn ->
            result =
              data
              |> Enum.map(&(&1 * 3))
              |> assign_to(step1)
              |> Enum.filter(&(&1 > 50))
              |> assign_to(step2)
              |> Enum.chunk_every(10)
              |> assign_to(step3)
              |> Enum.map(&Enum.sum/1)
              |> assign_to(step4)
              |> Enum.sort(:desc)
              |> assign_to(step5)
              |> Enum.take(5)

            {result, length(step1), length(step2), length(step3), length(step4), length(step5)}
          end
        },
        formatters: [{Console, comparison: true}]
      )
    end

    @doc """
    Run string processing benchmarks.
    """
    def run_string_benchmark do
      text = String.duplicate("hello world test string ", 100)

      Benchee.run(
        %{
          "String Traditional" => fn ->
            step1 = String.upcase(text)
            step2 = String.replace(step1, "TEST", "DATA")
            step3 = String.split(step2, " ")
            step4 = Enum.take(step3, 50)
            result = Enum.join(step4, "-")

            {result, String.length(step1), String.length(step2), length(step3), length(step4)}
          end,
          "String assign_to/2" => fn ->
            result =
              text
              |> String.upcase()
              |> assign_to(step1)
              |> String.replace("TEST", "DATA")
              |> assign_to(step2)
              |> String.split(" ")
              |> assign_to(step3)
              |> Enum.take(50)
              |> assign_to(step4)
              |> Enum.join("-")

            {result, String.length(step1), String.length(step2), length(step3), length(step4)}
          end
        },
        formatters: [{Console, comparison: true}]
      )
    end

    @doc """
    Run list processing benchmarks.
    """
    def run_list_benchmark do
      data = Enum.to_list(1..1000)

      Benchee.run(
        %{
          "List Traditional" => fn ->
            step1 = Enum.map(data, &(&1 * 2))
            step2 = Enum.filter(step1, &(rem(&1, 4) == 0))
            result = Enum.sum(step2)

            {result, length(step1), length(step2)}
          end,
          "List assign_to/2" => fn ->
            result =
              data
              |> Enum.map(&(&1 * 2))
              |> assign_to(step1)
              |> Enum.filter(&(rem(&1, 4) == 0))
              |> assign_to(step2)
              |> Enum.sum()

            {result, length(step1), length(step2)}
          end
        },
        formatters: [{Console, comparison: true}]
      )
    end

    @doc """
    Run map manipulation benchmarks.
    """
    def run_map_benchmark do
      map_data = Map.new(1..500, fn i -> {i, "value_#{i}"} end)

      Benchee.run(
        %{
          "Map Traditional" => fn ->
            step1 = Map.put(map_data, :new_key, "new_value")
            step2 = Map.update(step1, 1, "default", &("updated_" <> &1))
            step3 = Map.delete(step2, 2)
            step4 = Map.keys(step3)
            result = length(step4)

            {result, map_size(step1), map_size(step2), map_size(step3), length(step4)}
          end,
          "Map assign_to/2" => fn ->
            result =
              map_data
              |> Map.put(:new_key, "new_value")
              |> assign_to(step1)
              |> Map.update(1, "default", &("updated_" <> &1))
              |> assign_to(step2)
              |> Map.delete(2)
              |> assign_to(step3)
              |> Map.keys()
              |> assign_to(step4)
              |> length()

            {result, map_size(step1), map_size(step2), map_size(step3), length(step4)}
          end
        },
        formatters: [{Console, comparison: true}]
      )
    end

    @doc """
    Run comprehensive benchmark suite with all test types.
    """
    def run_comprehensive_benchmark do
      IO.puts("Running comprehensive PipeAssign benchmark suite...")
      IO.puts("=" <> String.duplicate("=", 60))

      IO.puts("\n1. Hot Path Benchmarks")
      IO.puts("-" <> String.duplicate("-", 30))
      run_hotpath_benchmark()

      IO.puts("\n2. Complex Pipeline Benchmarks")
      IO.puts("-" <> String.duplicate("-", 30))
      run_complex_benchmark()

      IO.puts("\n3. String Processing Benchmarks")
      IO.puts("-" <> String.duplicate("-", 30))
      run_string_benchmark()

      IO.puts("\n4. List Processing Benchmarks")
      IO.puts("-" <> String.duplicate("-", 30))
      run_list_benchmark()

      IO.puts("\n5. Map Manipulation Benchmarks")
      IO.puts("-" <> String.duplicate("-", 30))
      run_map_benchmark()

      IO.puts("\nBenchmark suite completed!")
    end

    @doc """
    Get available benchmark types.
    """
    def available_types do
      [:quick, :hotpath, :complex, :string, :list, :map, :comprehensive]
    end

    @doc """
    Run a specific benchmark type.
    """
    def run_benchmark(type) do
      case type do
        :quick -> run_quick_comparison()
        :hotpath -> run_hotpath_benchmark()
        :complex -> run_complex_benchmark()
        :string -> run_string_benchmark()
        :list -> run_list_benchmark()
        :map -> run_map_benchmark()
        :comprehensive -> run_comprehensive_benchmark()
        _ -> {:error, "Unknown benchmark type: #{type}"}
      end
    end
  else
    # Fallback functions when Benchee is not available
    def run_quick_comparison do
      {:error, "Benchee is not available in this environment"}
    end

    def run_hotpath_benchmark do
      {:error, "Benchee is not available in this environment"}
    end

    def run_complex_benchmark do
      {:error, "Benchee is not available in this environment"}
    end

    def run_string_benchmark do
      {:error, "Benchee is not available in this environment"}
    end

    def run_list_benchmark do
      {:error, "Benchee is not available in this environment"}
    end

    def run_map_benchmark do
      {:error, "Benchee is not available in this environment"}
    end

    def run_comprehensive_benchmark do
      {:error, "Benchee is not available in this environment"}
    end

    def available_types do
      []
    end

    def run_benchmark(_type) do
      {:error, "Benchee is not available in this environment"}
    end
  end
end
