# PipeAssign

[![Hex.pm](https://img.shields.io/hexpm/v/pipe_assign.svg)](https://hex.pm/packages/pipe_assign)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/pipe_assign)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

PipeAssign provides a macros for capturing intermediate values in Elixir pipe chains without breaking the flow or requiring separate assignment statements.

## ⚠️ Warning

This project was created for research purposes. To understand how `assign_to/2` and `match_to/2` will affect codebase:
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
```

Now you have both clean pipe flow, access to step1, step2, result variables and no
assignment before pipes.

In Elixir `=` is a match operator. So we can match against it:

```elixir
    iex> import PipeAssign
    iex> %{a: 1, b: 2}
    ...> |> match_to(%{a: x})
    %{b: 2, a: 1}
    iex> x
    1
```

`assign_to/2` is the same as `match_to/2`:

```elixir
    # These are equivalent
    value |> match_to(result)
    value |> assign_to(result)
```

This is just for readability.

## Installation

Add `pipe_assign` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pipe_assign, "~> 2.0"}
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

### Without Import

Use `require` to call macros with fully qualified name:

```elixir
require PipeAssign

[1, 2, 3, 4, 5]
|> Enum.filter(&rem(&1, 2) == 0)
|> PipeAssign.assign_to(evens)

# evens == [2, 4]
```

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

### Performance Impact

Based on benchmarks with MacBook Air M1 16GB, the overhead are within the margin of error.

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
Name                           ips        average     deviation      median         99th %
Hot Path Traditional          7.84 M      127.63 ns   ±10284.16%     125 ns         125 ns
Hot Path assign_to/2          7.83 M      127.72 ns    ±9866.55%     125 ns         125 ns

String assign_to/2           21.44 K       46.65 μs    ±10.07%       46.96 μs       57.04 μs
String Traditional           21.34 K       46.87 μs     ±9.62%       47.29 μs       57.08 μs

Complex assign_to/2          25.47 K       39.27 μs    ±11.90%       40.21 μs          52 μs
Complex Traditional          25.38 K       39.40 μs    ±12.26%       40.42 μs          52 μs

List Traditional             54.28 K       18.42 μs    ±22.83%       18.21 μs       20.96 μs
List assign_to/2             54.05 K       18.50 μs    ±22.93%       18.25 μs       21.38 μs

Map Traditional             239.71 K        4.17 μs    ±204.30%       4.04 μs        6.04 μs
Map assign_to/2             239.09 K        4.18 μs    ±200.79%       4.08 μs        5.96 μs

Comparison:
Hot Path Traditional        7.84 M
Hot Path assign_to/2        7.83 M - 1.00x slower +0.0906 ns

String assign_to/2          21.44 K
String Traditional          21.34 K - 1.00x slower +0.22 μs

Complex assign_to/2         25.47 K
Complex Traditional         25.38 K - 1.00x slower +0.135 μs

List Traditional            54.28 K
List assign_to/2            54.05 K - 1.00x slower +0.0780 μs

Map Traditional             239.71 K
Map assign_to/2             239.09 K - 1.00x slower +0.0108 μs
```

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

## Documentation

Full documentation is available at [https://hexdocs.pm/pipe_assign](https://hexdocs.pm/pipe_assign).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
