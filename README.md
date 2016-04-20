# SetupTag

SetupTag allows you to create a test context by easily mix and match
test setup functions selected by the tags applied to your test or module.

Well, it's actually a feature of ExUnit, but this module lets you
reuse and mix functions over different modules.

## Installation

[Available in Hex](https://hex.pm/packages/setup_tag), the package can be installed as:

  1. Add setup_tag to your list of dependencies in `mix.exs`:

        def deps do
          [{:setup_tag, "~> 0.1.2", only: [:test}]
        end

## Usage

See `setup_tag_text.exs` for a complete example

```elixir
defmodule SetupTagTest do

  use ExUnit.Case
  use SetupTag
  
  def one(ctx), do: {:ok, Map.put(ctx, :one, 1)}
  def dup_one(ctx = %{one: x}), do: {:ok, %{ctx | one: x + x }}
  def mul_one(ctx = %{one: x}, y), do: {:ok, %{ctx | one: x * y }}
  
  @tag setup: [:one, :dup_one, mul_one: 3]
  test "combining with a function with arguments", %{one: x} do
    assert x == 6
  end
end
```
