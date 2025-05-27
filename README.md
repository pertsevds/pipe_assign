# PipeAssign

[![Hex.pm](https://img.shields.io/hexpm/v/pipe_assign.svg)](https://hex.pm/packages/pipe_assign)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/pipe_assign)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

PipeAssign provides a macro for capturing intermediate values in Elixir pipe chains without breaking the flow or requiring separate assignment statements.

## ⚠️ Warning

This project was created for research purposes. To understand how `assign_to/2` will affect codebase:
- What performance overhead would be?
- What readability would be, worse or better?

## The Problem

Traditional Elixir code often forces you to choose between clean pipe flow and intermediate value access:

```elixir
# Clean pipes, but no intermediate access
final_result = data |> transform() |> process() |> finalize()

# Intermediate access, but broken flow
step1 = data |> transform()
step2 = step1 |> process()
final_result = step2 |> finalize()
```

## The Solution

PipeAssign bridges this gap by allowing you to capture values while maintaining the elegance of pipe operators:

```elixir
import PipeAssign

data
|> transform()
|> assign_to(step1)  # Capture without breaking flow
|> process()
|> assign_to(step2)
|> finalize()
|> assign_to(result) # Assign to result variable

# Now you have both clean pipe flow, access to step1, step2, result variables and no
# assignment before pipes.
```

## Installation

Add `pipe_assign` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pipe_assign, "~> 1.0"}
  ]
end
```

## Usage

### Basic Usage

Import the module and use `assign_to/2` in your pipes:

```elixir
import PipeAssign

[1, 2, 3]
|> Enum.map(&(&1 * 2))
|> Enum.sum()
|> assign_to(result)

# result == 12
```

### Multiple Assignments

Chain multiple assignments in a single pipe:

```elixir
import PipeAssign

%{name: "John", age: 30}
|> Map.put(:email, "john@example.com")
|> assign_to(with_email)
|> Map.put(:active, true)
|> assign_to(complete)
|> Map.keys()
|> length()
|> assign_to(result)

# result == 4
# with_email == %{name: "John", age: 30, email: "john@example.com"}
# complete == %{name: "John", age: 30, email: "john@example.com", active: true}
```

### Existing Variables

Works seamlessly with existing variables (no compiler warnings):

```elixir
import PipeAssign

temp = nil

"hello world"
|> String.upcase()
|> assign_to(temp)
|> String.length()
|> assign_to(length)

# length == 11
# temp == "HELLO WORLD"
```

### Without Import

Use the fully qualified name for occasional use:

```elixir
[1, 2, 3, 4, 5]
|> Enum.filter(&rem(&1, 2) == 0)
|> PipeAssign.assign_to(evens)

# evens == [2, 4]
```

## Use Cases

**Recommended for:**
- **Debugging**: Capture intermediate states for inspection during development
- **Logging**: Store values for audit trails or monitoring in non-critical paths
- **Conditional Logic**: Make decisions based on intermediate results
- **Testing**: Verify intermediate transformations in complex pipelines
- **Development**: Avoid redundant computations by caching intermediate results during prototyping

**⚠️ Performance Note**: This macro introduces minimal overhead (~1% or less) and can be used freely in most scenarios. See [Performance Considerations](#performance-considerations) for details.

## Examples

### Data Processing Pipeline

```elixir
import PipeAssign

def process_user_data(raw_data) do
  raw_data
  |> Jason.decode!()
  |> assign_to(parsed_json)
  |> normalize_keys()
  |> assign_to(normalized)
  |> validate_required_fields()
  |> assign_to(validated)
  |> save_to_database()
  |> assign_to(result)

  Logger.info("Processed user data", %{
    raw_size: byte_size(raw_data),
    parsed_keys: Map.keys(parsed_json),
    normalized_count: map_size(normalized),
    validation_status: validated.status
  })

  result
end
```

### API Response Processing

```elixir
import PipeAssign

def fetch_and_process_posts(user_id) do
  user_id
  |> fetch_user_posts()
  |> assign_to(raw_posts)
  |> Enum.filter(&(&1.published))
  |> assign_to(published_posts)
  |> Enum.sort_by(&(&1.created_at), :desc)
  |> assign_to(sorted_posts)
  |> Enum.take(10)
  |> format_for_api()
  |> tap(fn _ ->
    Analytics.track("posts_fetched", %{
      user_id: user_id,
      total_posts: length(raw_posts),
      published_posts: length(published_posts),
      returned_posts: length(sorted_posts)
    })
  end)
end
```

## Smart Variable Handling

The macro automatically detects whether the variable already exists in the current scope:

- If the variable doesn't exist, it creates a new one using `var!()`
- If the variable already exists, it reassigns it using regular assignment and references
 the old value to avoid "unused variable" warnings

This means you can use the same macro whether the variable is new or existing.

## Performance Considerations

While `assign_to/2` provides significant convenience for debugging and intermediate value capture, benchmarking shows it introduces minimal performance overhead:

- **Hot path operations**: ~1% slower (1% slower)
- **String processing**: Essentially no impact
- **Complex pipelines**: Negligible impact (~0.3% slower)
- **List operations**: Essentially no impact (~0.001% slower)
- **Map operations**: Essentially no impact (~0.3% slower)
- **Memory usage**: Slight increase due to intermediate variable storage

### When to Use

✅ **Good use cases:**
- Development and debugging workflows
- Complex data processing pipelines
- Non-critical application paths
- Code where readability and debugging outweigh small performance costs

❌ **Consider alternatives for:**
- Extremely performance-critical hot paths
- Memory-constrained environments with strict limitations
- High-frequency loops

### Performance Impact

Based on benchmarking with MacBook Air M1 16GB, the overhead is minimal:

```elixir
# Hot path - 1% slower, acceptable for most use cases:
data |> transform() |> assign_to(intermediate) |> process()

# Complex pipelines - negligible impact, use freely:
data
|> complex_transform()
|> assign_to(step1)  # <-- Minimal overhead (~0.1 μs)
|> another_complex_operation()

# Traditional assignment only needed for extreme performance requirements:
intermediate = data |> transform()
intermediate |> process()
```

## Benchmarking

PipeAssign includes a comprehensive benchmarking suite to help you understand the performance implications in your specific use cases.

### Running Benchmarks

```bash
# Quick comparison (recommended for most users)
mix benchmark

# Comprehensive benchmark suite (takes longer)
mix benchmark --full

# Specific benchmark types
mix benchmark --type=hotpath    # Performance-critical scenarios
mix benchmark --type=complex    # Multi-step pipelines
mix benchmark --type=string     # String processing
mix benchmark --type=list       # List operations
mix benchmark --type=map        # Map manipulations
```

### Understanding Results

The benchmarks compare `assign_to/2` against traditional assignment patterns across various scenarios. All performance measurements were conducted on MacBook Air M1 16GB running macOS.

- **Hot path scenarios**: Simple operations where overhead is most visible
- **Complex pipelines**: Multi-step transformations where overhead is proportionally smaller
- **Different data sizes**: Small, medium, and large datasets
- **Various data types**: Lists, strings, maps, and mixed operations

### Sample Results

Latest benchmark results (MacBook Air M1 16GB, macOS) show:

```
Name                             ips        average  deviation         median         99th %
Hot Path Traditional          7.69 M      130.07 ns  ±5190.73%         125 ns         167 ns
Hot Path assign_to/2          7.62 M      131.15 ns  ±5253.34%         125 ns         167 ns

String assign_to/2           21.12 K       47.35 μs    ±11.25%       47.50 μs       61.54 μs
String Traditional           21.01 K       47.60 μs    ±29.76%       47.50 μs       62.67 μs

Complex Traditional          24.70 K       40.48 μs    ±14.02%       40.92 μs       64.90 μs
Complex assign_to/2          24.64 K       40.59 μs    ±14.10%       41.04 μs       64.24 μs

List Traditional             52.73 K       18.96 μs    ±21.24%       18.67 μs       24.00 μs
List assign_to/2             52.72 K       18.97 μs    ±21.30%       18.67 μs       23.18 μs

Map Traditional             236.04 K        4.24 μs   ±176.91%        4.13 μs        6.42 μs
Map assign_to/2             235.40 K        4.25 μs   ±177.41%        4.13 μs        6.29 μs

Comparison:
Hot Path Traditional          7.69 M
Hot Path assign_to/2          7.62 M - 1.01x slower +1.08 ns

String assign_to/2           21.12 K
String Traditional           21.01 K - 1.01x slower +0.25 μs

Complex Traditional          24.70 K
Complex assign_to/2          24.64 K - 1.00x slower +0.106 μs

List Traditional             52.73 K
List assign_to/2             52.72 K - 1.00x slower +0.00176 μs

Map Traditional             236.04 K
Map assign_to/2             235.40 K - 1.00x slower +0.0114 μs
```

### Key Insights

- **Hot paths**: ~1% overhead (1% slower)
- **String operations**: Essentially no impact
- **Complex pipelines**: Negligible difference (~0.3% slower)
- **List operations**: Essentially no impact (~0.001% slower)
- **Map operations**: Essentially no impact (~0.3% slower)
- **Real-world impact**: Minimal performance cost

**Test Environment**: All benchmarks performed on MacBook Air M1 16GB, macOS, Elixir 1.18.3, Erlang/OTP 27.3.3.

Use these benchmarks to make informed decisions about where to use `assign_to/2` in your codebase.

## Testing

The library includes comprehensive test coverage. Run the tests with:

```bash
mix test
```

To check test coverage:

```bash
mix test --cover
```

## Support Matrix

Tests automatically run against a matrix of OTP and Elixir Versions, see the [ci.yml](https://github.com/pertsevds/pipe_assign/tree/main/.github/workflows/ci.yml) for details.

| OTP \ Elixir | 1.15 | 1.16 | 1.17 | 1.18 |
|:------------:|:----:|:----:|:----:|:----:|
| 25           | ✅  | ✅  | ✅  | ✅  |
| 26           | ✅  | ✅  | ✅  | ✅  |
| 27           | N/A  | N/A  | ✅  | ✅  |
| 28           | N/A  | N/A  | N/A  | ✅  |

## Documentation

Full documentation is available at [https://hexdocs.pm/pipe_assign](https://hexdocs.pm/pipe_assign).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
