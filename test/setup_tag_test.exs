defmodule SetupTagTest.Mars do
  def moo(ctx), do: {:ok, Map.put(ctx, :moo, "Mars Moo")}
  def moo(ctx, thing), do: {:ok, Map.put(ctx, :moo, "Mars #{thing}")}

  def one(ctx, value), do: {:ok, Map.put(ctx, :one, value)}
end


defmodule SetupTagTest do

  use ExUnit.Case
  use SetupTag
  alias __MODULE__.{Mars}

  def moo(ctx), do: {:ok, Map.put(ctx, :moo, "Earth Moo")}
  def one(ctx), do: {:ok, Map.put(ctx, :one, 1)}
  def dup_one(ctx = %{one: x}), do: {:ok, %{ctx | one: x + x }}
  def mul_one(ctx = %{one: x}, y), do: {:ok, %{ctx | one: x * y }}

  @mars_moo &Mars.moo/1
  @mars_moon &Mars.moo/2

  @tag setup: :moo
  test "requesting local moo to be injected", %{moo: x} do
    assert x == "Earth Moo"
  end

  @tag setup: &Mars.moo/1
  test "requesting remote moo", %{moo: x} do
    assert x == "Mars Moo"
  end

  @tag setup: @mars_moo
  test "requesting remote moo with attribute", %{moo: x} do
    assert x == "Mars Moo"
  end

  @tag setup: [:one, :dup_one]
  test "combining contexts", %{one: x} do
    assert x == 2
  end

  @tag setup: [:one, :dup_one, mul_one: 3]
  test "combining with a function with arguments", %{one: x} do
    assert x == 6
  end

  @tag setup: [:one, @mars_moo]
  test "combining one and mars", %{moo: x, one: 1} do
    assert x == "Mars Moo"
  end

  @tag setup: [{@mars_moon, "Moon"}]
  @tag setup_one: :one
  test "remove function with additional arguments", %{moo: x, one: 1} do
    assert x == "Mars Moon"
  end

  @tag setup_one: :one
  test "only setup_one", %{one: x} do
    assert x == 1
  end

  @tag setup: {&Mars.one/2, 99}
  test "only function reference", %{one: x} do
    assert x == 99
  end

  @tag setup: [{&Mars.one/2, 99}]
  test "only function reference in list", %{one: x} do
    assert x == 99
  end

end

