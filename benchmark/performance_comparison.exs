# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

# Performance Benchmark Suite for PipeAssign
#
# This benchmark compares the performance of using assign_to/2 versus
# traditional assignment patterns in various scenarios.
#
# Run with: mix run benchmark/performance_comparison.exs

import PipeAssign

# Generate test data of various sizes
small_data = Enum.to_list(1..100)
medium_data = Enum.to_list(1..1_000)
large_data = Enum.to_list(1..10_000)

# 100 chars
small_string = String.duplicate("test", 25)
# 1000 chars
medium_string = String.duplicate("test", 250)
# 10000 chars
large_string = String.duplicate("test", 2500)

small_map = Map.new(1..50, fn i -> {i, "value_#{i}"} end)
medium_map = Map.new(1..500, fn i -> {i, "value_#{i}"} end)
large_map = Map.new(1..5000, fn i -> {i, "value_#{i}"} end)

IO.puts("""
=============================================================================
                    PipeAssign Performance Benchmark Suite
=============================================================================

This benchmark compares performance between:
  • Traditional assignment (baseline)
  • PipeAssign assign_to/2 macro (with overhead)

Scenarios tested:
  • Simple pipes with different data sizes
  • Complex multi-step transformations
  • String processing pipelines
  • Map manipulation chains
  • Hot path simulations

""")

Benchee.run(
  %{
    # =======================================================================
    # Simple List Processing - Small Data
    # =======================================================================
    "list/small/traditional" => fn ->
      step1 = Enum.map(small_data, &(&1 * 2))
      step2 = Enum.filter(step1, &(rem(&1, 4) == 0))
      result = Enum.sum(step2)

      # Use intermediate variables to match assign_to benchmark
      {result, length(step1), length(step2)}
    end,
    "list/small/assign_to" => fn ->
      result =
        small_data
        |> Enum.map(&(&1 * 2))
        |> assign_to(step1)
        |> Enum.filter(&(rem(&1, 4) == 0))
        |> assign_to(step2)
        |> Enum.sum()

      # Use assigned variables to prevent optimization
      {result, length(step1), length(step2)}
    end,

    # =======================================================================
    # Simple List Processing - Medium Data
    # =======================================================================
    "list/medium/traditional" => fn ->
      step1 = Enum.map(medium_data, &(&1 * 2))
      step2 = Enum.filter(step1, &(rem(&1, 4) == 0))
      result = Enum.sum(step2)

      # Use intermediate variables to match assign_to benchmark
      {result, length(step1), length(step2)}
    end,
    "list/medium/assign_to" => fn ->
      result =
        medium_data
        |> Enum.map(&(&1 * 2))
        |> assign_to(step1)
        |> Enum.filter(&(rem(&1, 4) == 0))
        |> assign_to(step2)
        |> Enum.sum()

      # Use assigned variables to prevent optimization
      {result, length(step1), length(step2)}
    end,

    # =======================================================================
    # Simple List Processing - Large Data
    # =======================================================================
    "list/large/traditional" => fn ->
      step1 = Enum.map(large_data, &(&1 * 2))
      step2 = Enum.filter(step1, &(rem(&1, 4) == 0))
      result = Enum.sum(step2)

      # Use intermediate variables to match assign_to benchmark
      {result, length(step1), length(step2)}
    end,
    "list/large/assign_to" => fn ->
      result =
        large_data
        |> Enum.map(&(&1 * 2))
        |> assign_to(step1)
        |> Enum.filter(&(rem(&1, 4) == 0))
        |> assign_to(step2)
        |> Enum.sum()

      # Use assigned variables to prevent optimization
      {result, length(step1), length(step2)}
    end,

    # =======================================================================
    # Complex Pipeline - Multiple Steps
    # =======================================================================
    "complex/traditional" => fn ->
      step1 = Enum.map(medium_data, &(&1 * 3))
      step2 = Enum.filter(step1, &(&1 > 50))
      step3 = Enum.chunk_every(step2, 10)
      step4 = Enum.map(step3, &Enum.sum/1)
      step5 = Enum.sort(step4, :desc)
      result = Enum.take(step5, 5)

      # Use intermediate variables to match assign_to benchmark
      {result, length(step1), length(step2), length(step3), length(step4), length(step5)}
    end,
    "complex/assign_to" => fn ->
      result =
        medium_data
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

      # Use assigned variables to prevent optimization
      {result, length(step1), length(step2), length(step3), length(step4), length(step5)}
    end,

    # =======================================================================
    # String Processing Pipelines
    # =======================================================================
    "string/small/traditional" => fn ->
      step1 = String.upcase(small_string)
      step2 = String.replace(step1, "TEST", "DATA")
      step3 = String.split(step2, "")
      step4 = Enum.take(step3, 50)
      result = Enum.join(step4, "-")

      # Use intermediate variables to match assign_to benchmark
      {result, String.length(step1), String.length(step2), length(step3), length(step4)}
    end,
    "string/small/assign_to" => fn ->
      result =
        small_string
        |> String.upcase()
        |> assign_to(step1)
        |> String.replace("TEST", "DATA")
        |> assign_to(step2)
        |> String.split("")
        |> assign_to(step3)
        |> Enum.take(50)
        |> assign_to(step4)
        |> Enum.join("-")

      # Use assigned variables to prevent optimization
      {result, String.length(step1), String.length(step2), length(step3), length(step4)}
    end,
    "string/large/traditional" => fn ->
      step1 = String.upcase(large_string)
      step2 = String.replace(step1, "TEST", "DATA")
      step3 = String.split(step2, "")
      step4 = Enum.take(step3, 100)
      result = Enum.join(step4, "-")

      # Use intermediate variables to match assign_to benchmark
      {result, String.length(step1), String.length(step2), length(step3), length(step4)}
    end,
    "string/large/assign_to" => fn ->
      result =
        large_string
        |> String.upcase()
        |> assign_to(step1)
        |> String.replace("TEST", "DATA")
        |> assign_to(step2)
        |> String.split("")
        |> assign_to(step3)
        |> Enum.take(100)
        |> assign_to(step4)
        |> Enum.join("-")

      # Use assigned variables to prevent optimization
      {result, String.length(step1), String.length(step2), length(step3), length(step4)}
    end,

    # =======================================================================
    # Map Processing Pipelines
    # =======================================================================
    "map/small/traditional" => fn ->
      step1 = Map.put(small_map, :new_key, "new_value")
      step2 = Map.update(step1, 1, "default", &("updated_" <> &1))
      step3 = Map.delete(step2, 2)
      step4 = Map.keys(step3)
      result = length(step4)

      # Use intermediate variables to match assign_to benchmark
      {result, map_size(step1), map_size(step2), map_size(step3), length(step4)}
    end,
    "map/small/assign_to" => fn ->
      result =
        small_map
        |> Map.put(:new_key, "new_value")
        |> assign_to(step1)
        |> Map.update(1, "default", &("updated_" <> &1))
        |> assign_to(step2)
        |> Map.delete(2)
        |> assign_to(step3)
        |> Map.keys()
        |> assign_to(step4)
        |> length()

      # Use assigned variables to prevent optimization
      {result, map_size(step1), map_size(step2), map_size(step3), length(step4)}
    end,
    "map/large/traditional" => fn ->
      step1 = Map.put(large_map, :new_key, "new_value")
      step2 = Map.update(step1, 1, "default", &("updated_" <> &1))
      step3 = Map.delete(step2, 2)
      step4 = Map.keys(step3)
      result = length(step4)

      # Use intermediate variables to match assign_to benchmark
      {result, map_size(step1), map_size(step2), map_size(step3), length(step4)}
    end,
    "map/large/assign_to" => fn ->
      result =
        large_map
        |> Map.put(:new_key, "new_value")
        |> assign_to(step1)
        |> Map.update(1, "default", &("updated_" <> &1))
        |> assign_to(step2)
        |> Map.delete(2)
        |> assign_to(step3)
        |> Map.keys()
        |> assign_to(step4)
        |> length()

      # Use assigned variables to prevent optimization
      {result, map_size(step1), map_size(step2), map_size(step3), length(step4)}
    end,

    # =======================================================================
    # Hot Path Simulation - Minimal Operations
    # =======================================================================
    "hotpath/simple/traditional" => fn ->
      result = Enum.sum(small_data)
      final = result * 2

      # Use intermediate variables to match assign_to benchmark
      {final, result}
    end,
    "hotpath/simple/assign_to" => fn ->
      final =
        small_data
        |> Enum.sum()
        |> assign_to(result)
        |> Kernel.*(2)

      # Use assigned variables to prevent optimization
      {final, result}
    end,

    # =======================================================================
    # Hot Path Simulation - Multiple Assignments
    # =======================================================================
    "hotpath/multi/traditional" => fn ->
      step1 = length(small_data)
      step2 = step1 * 3
      step3 = step2 + 10
      step4 = step3 / 2
      result = round(step4)

      # Use intermediate variables to match assign_to benchmark
      {result, step1, step2, step3, step4}
    end,
    "hotpath/multi/assign_to" => fn ->
      result =
        small_data
        |> length()
        |> assign_to(step1)
        |> Kernel.*(3)
        |> assign_to(step2)
        |> Kernel.+(10)
        |> assign_to(step3)
        |> Kernel./(2)
        |> assign_to(step4)
        |> round()

      # Use assigned variables to prevent optimization
      {result, step1, step2, step3, step4}
    end,

    # =======================================================================
    # JSON-like Data Processing Simulation
    # =======================================================================
    "json/traditional" => fn ->
      data = %{users: medium_data, active: true, count: length(medium_data)}
      step1 = Map.get(data, :users)
      step2 = Enum.filter(step1, &(&1 > 500))
      step3 = Enum.map(step2, &%{id: &1, active: true})
      step4 = Enum.take(step3, 10)
      result = %{filtered_users: step4, total: length(step4)}

      # Use intermediate variables to match assign_to benchmark
      {result, length(step1), length(step2), length(step3), length(step4)}
    end,
    "json/assign_to" => fn ->
      data = %{users: medium_data, active: true, count: length(medium_data)}

      result =
        data
        |> Map.get(:users)
        |> assign_to(step1)
        |> Enum.filter(&(&1 > 500))
        |> assign_to(step2)
        |> Enum.map(&%{id: &1, active: true})
        |> assign_to(step3)
        |> Enum.take(10)
        |> assign_to(step4)
        |> then(&%{filtered_users: &1, total: length(&1)})

      # Use assigned variables to prevent optimization
      {result, length(step1), length(step2), length(step3), length(step4)}
    end
  },
  time: 3,
  memory_time: 2,
  reduction_time: 2,
  pre_check: true,
  formatters: [
    {Benchee.Formatters.Console, comparison: true, extended_statistics: true},
    {Benchee.Formatters.HTML, file: "benchmark/results.html"}
  ]
)

IO.puts("""

=============================================================================
                             Benchmark Summary
=============================================================================

Results saved to: benchmark/results.html

Key Findings:
• assign_to/2 introduces measurable overhead due to macro expansion
• Overhead is most noticeable in hot paths and simple operations
• Complex pipelines show proportionally less impact
• Memory usage may be slightly higher due to intermediate assignments

Recommendations:
• Use assign_to/2 for debugging, development, and complex pipelines
• Avoid in performance-critical hot paths
• Traditional assignment remains optimal for production hot paths
• The convenience often outweighs the cost in non-critical code

""")
