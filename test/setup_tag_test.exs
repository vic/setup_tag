defmodule SetupTag.Example do
  def bar(ctx = %{foo: foo}, baz) do
    {:ok, %{ctx | foo: "#{foo}bar#{baz}"}}
  end

  def setup_foo(ctx) do
    {:ok, Map.put(ctx, :foo, "foo")}
  end
end

defmodule SetupTagTest do
  use ExUnit.Case
  use SetupTag

  @moduletag :setup_two
  @ctx %{one: 1}

  setup(tags) do
    SetupTag.setup(tags, @ctx)
  end

  def setup_double(ctx) do
    {:ok, %{ctx | one: 2}}
  end

  def setup_two(ctx = %{one: one}) do
    {:ok, Map.put(ctx, :two, one * 2)}
  end

  test "mixes initial context with module tag", %{one: one, two: two} do
    assert one + one == two
  end

  @tag :setup_double
  test "combines test local tag then module tag", %{one: 2, two: 4} do
    assert :ok
  end

  @tag setup_foo: SetupTag.Example
  test "calling setup function from other module", %{foo: foo} do
    assert foo == "foo"
  end

  @tag setup_foo: SetupTag.Example
  @tag setup_foo_bar: {SetupTag.Example, bar: ["baz"]}
  test "remote function called with context as first argument", %{foo: foo} do
    assert foo == "foobarbaz"
  end

end
