# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule ReadmeTest do
  @moduledoc """
  Tests from README.md.
  """

  use ExUnit.Case

  import PipeAssign

  test "data processing pipeline example concept" do
    raw_data = ~s({"name": "test", "active": true})

    raw_data
    |> Jason.decode!()
    |> assign_to(parsed_json)
    |> Map.put(:processed, true)
    |> assign_to(normalized)
    |> Map.keys()
    |> length()
    |> assign_to(result)

    assert result == 3
    assert Map.get(parsed_json, "name") == "test"
    assert Map.get(normalized, :processed) == true
  end

  test "solution example concept from README" do
    data = %{raw: "test"}

    data
    |> Map.put(:transformed, true)
    |> assign_to(step1)
    |> Map.put(:processed, true)
    |> assign_to(step2)
    |> Map.put(:finalized, true)
    |> assign_to(result)

    assert Map.get(result, :finalized) == true
    assert Map.get(step1, :transformed) == true
    assert Map.get(step2, :processed) == true
    refute Map.has_key?(step1, :processed)
    refute Map.has_key?(step1, :finalized)
  end
end
