# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule WarningTest do
  use ExUnit.Case

  import PipeAssign

  test "BIF functions no longer warn before assign_to" do
    # Test length/1 (previously warned)
    result1 =
      [1, 2, 3, 4, 5]
      |> length()
      |> assign_to(len_var)

    # Test tuple_size/1 (previously warned)
    result2 =
      {1, 2, 3, 4}
      |> tuple_size()
      |> assign_to(tuple_var)

    # Test byte_size/1 (previously warned)
    result3 =
      "hello world"
      |> byte_size()
      |> assign_to(byte_var)

    # Test hd/1 (previously warned)
    result4 =
      [10, 20, 30]
      |> hd()
      |> assign_to(head_var)

    # Test tl/1 (previously warned)
    result5 =
      [10, 20, 30]
      |> tl()
      |> assign_to(tail_var)

    # Test map_size/1 (check if it warned)
    result6 =
      %{a: 1, b: 2, c: 3}
      |> map_size()
      |> assign_to(map_var)

    # Verify results
    assert result1 == 5
    assert len_var == 5

    assert result2 == 4
    assert tuple_var == 4

    assert result3 == 11
    assert byte_var == 11

    assert result4 == 10
    assert head_var == 10

    assert result5 == [20, 30]
    assert tail_var == [20, 30]

    assert result6 == 3
    assert map_var == 3
  end

  test "chaining multiple BIF functions works without warnings" do
    final =
      [1, 2, 3, 4, 5, 6]
      |> length()
      |> assign_to(list_length)
      |> then(fn len -> {len, len * 2, len * 3} end)
      |> tuple_size()
      |> assign_to(tuple_length)
      |> then(fn size -> String.duplicate("x", size) end)
      |> byte_size()
      |> assign_to(string_size)

    assert final == 3
    assert list_length == 6
    assert tuple_length == 3
    assert string_size == 3
  end
end
