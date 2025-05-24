# Benchmarks

This directory contains performance benchmarks for PipeAssign. These benchmarks are **development-only** and are **not included** in the distributed Hex package.

## Purpose

The benchmarks compare the performance of `assign_to/2` macro against traditional assignment patterns across various scenarios. Results show minimal overhead (~1% or less), making `assign_to/2` suitable for general use.

## Running Benchmarks

Use the Mix task to run benchmarks:

```bash
# Quick comparison (recommended for most users)
mix benchmark

# Comprehensive benchmark suite  
mix benchmark --full

# Specific benchmark types
mix benchmark --type=hotpath    # Performance-critical scenarios
mix benchmark --type=complex    # Multi-step pipelines  
mix benchmark --type=string     # String processing
mix benchmark --type=list       # List operations
mix benchmark --type=map        # Map manipulations
```

## Requirements

Benchmarks require the `dev` environment where Benchee is available:

```bash
MIX_ENV=dev mix benchmark
```

## Benchmark Categories

- **Hot Path**: Simple operations showing ~1% overhead (+1.08 ns)
- **Complex**: Multi-step transformations with negligible overhead (+0.106 μs)
- **String**: String processing operations (sometimes faster with assign_to/2)
- **List**: List manipulation and processing (essentially no overhead)
- **Map**: Map operations and transformations (essentially no overhead, +0.0114 μs)

## Implementation

The `benchmarks.ex` file contains the `PipeAssign.Benchmarks` module with all benchmark logic. The Mix task dynamically loads this module at runtime, ensuring it's not included in the compiled package.

## Test Environment

All benchmark results are based on testing performed on:
- **Hardware**: MacBook Air M1 16GB RAM
- **Operating System**: macOS
- **Elixir Version**: 1.18.3
- **Erlang/OTP Version**: 27.3.3

**Latest Results**: `assign_to/2` shows minimal overhead (1.00x-1.01x slower) across all scenarios, making it suitable for general use. Performance characteristics will vary on different hardware configurations.