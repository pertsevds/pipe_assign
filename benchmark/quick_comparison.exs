# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

# Quick Performance Comparison
# Run with: mix run benchmark/quick_comparison.exs

import PipeAssign

# Test data
data = Enum.to_list(1..1000)
text = "hello world from elixir pipe assign benchmark test"

IO.puts("PipeAssign Quick Performance Comparison")
IO.puts("=======================================")

Benchee.run(
  %{
    "Traditional Assignment" => fn ->
      step1 = Enum.map(data, &(&1 * 2))
      step2 = Enum.filter(step1, &(rem(&1, 4) == 0))
      step3 = Enum.sum(step2)
      result = step3 / 100

      # Use intermediate variables to match assign_to benchmark
      {result, length(step1), length(step2), step3}
    end,
    "With assign_to/2" => fn ->
      result =
        data
        |> Enum.map(&(&1 * 2))
        |> assign_to(step1)
        |> Enum.filter(&(rem(&1, 4) == 0))
        |> assign_to(step2)
        |> Enum.sum()
        |> assign_to(step3)
        |> Kernel./(100)

      # Use assigned variables to prevent optimization
      {result, length(step1), length(step2), step3}
    end,
    "String Traditional" => fn ->
      step1 = String.upcase(text)
      step2 = String.replace(step1, " ", "_")
      step3 = String.split(step2, "_")
      result = length(step3)

      # Use intermediate variables to match assign_to benchmark
      {result, String.length(step1), String.length(step2), length(step3)}
    end,
    "String assign_to/2" => fn ->
      result =
        text
        |> String.upcase()
        |> assign_to(step1)
        |> String.replace(" ", "_")
        |> assign_to(step2)
        |> String.split("_")
        |> assign_to(step3)
        |> length()

      # Use assigned variables to prevent optimization
      {result, String.length(step1), String.length(step2), length(step3)}
    end,
    "Hot Path Traditional" => fn ->
      result = length(data)
      doubled = result * 2
      final = doubled + 10

      # Use intermediate variables to match assign_to benchmark
      {final, result, doubled}
    end,
    "Hot Path assign_to/2" => fn ->
      final =
        data
        |> length()
        |> assign_to(result)
        |> Kernel.*(2)
        |> assign_to(doubled)
        |> Kernel.+(10)

      # Use assigned variables to prevent optimization
      {final, result, doubled}
    end
  },
  time: 2,
  warmup: 1,
  formatters: [
    {Benchee.Formatters.Console, comparison: true}
  ]
)

IO.puts("\nKey Takeaways:")
IO.puts("• assign_to/2 adds overhead but improves debugging")
IO.puts("• Use traditional assignment in performance-critical code")
IO.puts("• assign_to/2 is ideal for development and complex pipelines")
