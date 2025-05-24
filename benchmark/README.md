# PipeAssign Benchmarking Suite

This directory contains comprehensive performance benchmarks for the PipeAssign library, comparing the performance of `assign_to/2` macro versus traditional assignment patterns.

**Test Environment**: All benchmarks were performed on MacBook Air M1 16GB, macOS, Elixir 1.18.3, Erlang/OTP 27.3.3 with JIT enabled.

## Quick Start

```bash
# Run quick comparison (recommended)
mix benchmark

# Run comprehensive benchmark suite
mix benchmark --full

# Run specific benchmark types
mix benchmark --type=hotpath
mix benchmark --type=complex
mix benchmark --type=string
```

## Available Benchmarks

### Quick Comparison (`quick_comparison.exs`)
Fast comparison of common patterns covering:
- List processing with multiple steps
- String manipulation pipelines  
- Hot path scenarios with minimal operations

### Comprehensive Suite (`performance_comparison.exs`)
Extensive benchmarks across multiple scenarios:
- **Data sizes**: Small (100), medium (1,000), large (10,000) elements
- **Operation types**: List, string, map processing
- **Pipeline complexity**: Simple, complex, and hot path scenarios
- **Memory usage**: Analysis of memory consumption patterns

## Benchmark Categories

### Hot Path Scenarios
Tests performance-critical code where overhead is most visible:
- Simple arithmetic operations
- Minimal data transformations
- Tight loops and high-frequency operations

### Complex Pipelines
Multi-step transformations where overhead is proportionally smaller:
- Data filtering and mapping
- Multiple transformation steps
- Real-world data processing patterns

### String Processing
Text manipulation benchmarks:
- Case transformations
- String splitting and joining
- Pattern replacement operations

### List Operations
Collection processing benchmarks:
- Enumeration functions
- Filtering and mapping
- Aggregation operations

### Map Manipulations
Dictionary/map processing benchmarks:
- Key-value operations
- Map transformations
- Structure modifications

## Understanding Results

### Sample Output
```
Name                             ips        average  deviation         median         99th %
hotpath/traditional        990.57 K        1.01 μs   ±702.07%           1 μs        1.13 μs
hotpath/assign_to          982.21 K        1.02 μs   ±594.38%           1 μs        1.13 μs

Comparison:
hotpath/traditional        990.57 K
hotpath/assign_to          982.21 K - 1.01x slower +0.00859 μs
```

### Key Metrics
- **ips**: Iterations per second (higher is better)
- **average**: Average execution time (lower is better)
- **deviation**: Statistical variation in measurements
- **median**: Middle value of all measurements
- **99th %**: 99th percentile response time

### Performance Impact Analysis
- **Hot paths**: ~1% overhead typical (+1.08 ns on MacBook Air M1 16GB)
- **String operations**: Essentially no impact (sometimes faster with assign_to/2)
- **Complex pipelines**: Negligible difference (+0.106 μs)
- **List operations**: Essentially no impact (~0.001% slower)
- **Memory usage**: Slight increase due to intermediate assignments

**Note**: Performance characteristics may vary significantly on different hardware architectures and system configurations.

## Benchmark Methodology

### Ensuring Accurate Results

**Critical**: All benchmarks ensure assigned variables are actually used to prevent Elixir compiler optimization:

```elixir
# ❌ WRONG - Compiler optimizes away unused variables
"assign_to/wrong" => fn ->
  data
  |> transform()
  |> assign_to(unused_var)  # Compiler removes this!
  |> final_operation()
end

# ✅ CORRECT - Variables are used, preventing optimization
"assign_to/correct" => fn ->
  result = data
  |> transform()
  |> assign_to(step1)
  |> final_operation()
  
  # Use assigned variables to prevent optimization
  {result, length(step1)}
end
```

### Why This Matters

Without using assigned variables, the Elixir compiler optimizes them away during compilation, making benchmarks measure optimized-away code rather than real `assign_to/2` performance. Our benchmarks use tuple returns to ensure all intermediate variables are actually referenced and measured.

### Validation

Each benchmark pair (traditional vs assign_to) performs identical operations and returns equivalent data structures to ensure fair comparison.

## Running Custom Benchmarks

### Creating New Benchmarks
1. Create a new `.exs` file in this directory
2. Import `PipeAssign` and define test scenarios
3. Use `Benchee.run/2` to execute comparisons

### Example Custom Benchmark
```elixir
import PipeAssign

data = Enum.to_list(1..1000)

Benchee.run(%{
  "traditional" => fn ->
    step1 = Enum.map(data, &(&1 * 2))
    Enum.sum(step1)
  end,
  "assign_to" => fn ->
    data
    |> Enum.map(&(&1 * 2))
    |> assign_to(step1)
    |> Enum.sum()
  end
}, time: 3, formatters: [{Benchee.Formatters.Console, comparison: true}])
```

## Interpreting Results for Your Use Case

### When to Use assign_to/2
✅ **Recommended for:**
- Development and debugging
- Complex data processing pipelines
- Non-critical application paths
- Code where readability > performance

### When to Avoid assign_to/2
❌ **Avoid in:**
- Extremely performance-critical hot paths where nanoseconds matter
- Memory-constrained environments with strict limitations
- High-frequency loops with sub-nanosecond timing requirements

### Decision Framework
1. **Measure first**: Run benchmarks with your actual data
2. **Consider context**: Development vs production code
3. **Evaluate trade-offs**: Debugging convenience vs performance
4. **Profile holistically**: Micro-optimizations vs overall system performance

## System Requirements

### Dependencies
- `benchee ~> 1.3` (automatically installed in `:dev` environment)
- Elixir 1.15+ recommended for optimal performance

### Hardware Considerations
- Results vary significantly across different hardware
- CPU architecture affects relative performance
- Memory size impacts large dataset benchmarks
- JIT compilation affects short-running benchmarks

**Reference System**: All included benchmark results were measured on:
- **Hardware**: MacBook Air M1 16GB RAM
- **OS**: macOS
- **Elixir**: 1.18.3
- **Erlang/OTP**: 27.3.3
- **JIT**: Enabled

Your results may differ based on your system configuration.

## Contributing

### Adding New Benchmarks
1. Focus on real-world scenarios
2. Test multiple data sizes
3. Include both assign_to and traditional variants
4. Document the specific use case being tested

### Benchmark Best Practices
- Use realistic data sizes
- Test multiple scenarios
- Include memory profiling for large datasets
- Document expected performance characteristics
- Consider statistical significance of results

## Results Archive

Benchmark results are saved to `results.html` for detailed analysis including:
- Statistical confidence intervals
- Memory usage patterns
- Performance trend analysis
- System environment details

View results by opening `benchmark/results.html` in your browser after running the comprehensive suite.

## Test Environment

All benchmark results and performance recommendations in this documentation are based on testing performed on:

- **Hardware**: MacBook Air M1 16GB RAM
- **Operating System**: macOS
- **Elixir Version**: 1.18.3
- **Erlang/OTP Version**: 27.3.3
- **JIT Compilation**: Enabled
- **CPU Cores**: 8 (Apple M1)

Performance characteristics will vary on different hardware configurations. We recommend running your own benchmarks to determine the specific impact in your environment.