# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule Mix.Tasks.Benchmark do
  @shortdoc "Run PipeAssign performance benchmarks"

  @moduledoc """
  Run performance benchmarks for PipeAssign.

  This task runs benchmarks comparing the performance of `assign_to/2` macro
  versus traditional assignment patterns.

  ## Usage

      # Run quick comparison (default)
      mix benchmark

      # Run comprehensive benchmark suite
      mix benchmark --full

      # Run specific benchmark type
      mix benchmark --type=hotpath
      mix benchmark --type=complex
      mix benchmark --type=string

  ## Options

    * `--full` - Run the comprehensive benchmark suite (takes longer)
    * `--type=TYPE` - Run specific benchmark type (hotpath, complex, string, list, map)
    * `--output=FILE` - Save HTML results to specified file

  ## Benchmark Types

    * `quick` - Fast comparison of common patterns (default)
    * `full` - Comprehensive test suite with multiple data sizes
    * `hotpath` - Focus on performance-critical scenarios
    * `complex` - Multi-step pipeline comparisons
    * `string` - String processing benchmarks
    * `list` - List processing benchmarks
    * `map` - Map manipulation benchmarks

  ## Test Environment

  All benchmark results and performance recommendations are based on testing performed on:

  - **Hardware**: MacBook Air M1 16GB RAM
  - **Operating System**: macOS
  - **Elixir Version**: 1.18.3
  - **Erlang/OTP Version**: 27.3.3
  - **JIT Compilation**: Enabled

  Performance characteristics will vary on different hardware configurations.

  """

  use Mix.Task

  # Benchmarks module is in bench/ directory for development only

  @impl Mix.Task
  def run(args) do
    if !Code.ensure_loaded?(Benchee) do
      Mix.shell().error("Benchee is not available. Make sure you're running in the dev environment:")
      Mix.shell().info("MIX_ENV=dev mix benchmark")
      System.halt(1)
    end

    {opts, _args, _invalid} =
      OptionParser.parse(args,
        switches: [full: :boolean, type: :string, output: :string],
        aliases: [f: :full, t: :type, o: :output]
      )

    case determine_benchmark_type(opts) do
      :quick ->
        run_quick_benchmark()

      :full ->
        run_full_benchmark(opts)

      {:specific, type} ->
        run_specific_benchmark(type, opts)
    end
  end

  defp determine_benchmark_type(opts) do
    cond do
      opts[:full] -> :full
      opts[:type] -> {:specific, opts[:type]}
      true -> :quick
    end
  end

  defp run_quick_benchmark do
    Mix.shell().info("Running quick PipeAssign benchmark...")

    case load_and_run_benchmark(:quick) do
      {:error, message} ->
        Mix.shell().error(message)
        System.halt(1)

      _ ->
        :ok
    end
  end

  defp run_full_benchmark(_opts) do
    Mix.shell().info("Running comprehensive PipeAssign benchmark suite...")

    case load_and_run_benchmark(:comprehensive) do
      {:error, message} ->
        Mix.shell().error(message)
        System.halt(1)

      _ ->
        :ok
    end
  end

  defp run_specific_benchmark(type, _opts) do
    type_atom = String.to_atom(type)

    available_types = get_available_benchmark_types()

    if type_atom in available_types do
      Mix.shell().info("Running #{type} benchmarks...")

      case load_and_run_benchmark(type_atom) do
        {:error, message} ->
          Mix.shell().error(message)
          System.halt(1)

        _ ->
          :ok
      end
    else
      Mix.shell().error("Unknown benchmark type: #{type}")
      available = Enum.join(available_types, ", ")
      Mix.shell().info("Available types: #{available}")
      System.halt(1)
    end
  end

  defp load_and_run_benchmark(type) do
    benchmark_file = Path.join([File.cwd!(), "bench", "benchmarks.ex"])

    if File.exists?(benchmark_file) do
      try do
        if !Code.ensure_loaded?(PipeAssign.Benchmarks) do
          Code.compile_file(benchmark_file)
        end

        apply(PipeAssign.Benchmarks, :run_benchmark, [type])
      rescue
        error ->
          {:error, "Failed to load benchmarks: #{Exception.message(error)}"}
      end
    else
      {:error, "Benchmark file not found at #{benchmark_file}"}
    end
  end

  defp get_available_benchmark_types do
    benchmark_file = Path.join([File.cwd!(), "bench", "benchmarks.ex"])

    if File.exists?(benchmark_file) do
      try do
        if !Code.ensure_loaded?(PipeAssign.Benchmarks) do
          Code.compile_file(benchmark_file)
        end

        apply(PipeAssign.Benchmarks, :available_types, [])
      rescue
        _error ->
          [:quick, :hotpath, :complex, :string, :list, :map, :comprehensive]
      end
    else
      [:quick, :hotpath, :complex, :string, :list, :map, :comprehensive]
    end
  end
end
