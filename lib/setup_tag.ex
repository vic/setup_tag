defmodule SetupTag do

  @moduledoc """
  SetupTag allows you to create a test context by easily mix and match
  test setup functions selected by the tags applied to your test or module.

  Well, it's actually a feature of ExUnit, but this module lets you
  reuse and mix functions over different modules.

  See setup_tag_test.exs for a more real example usage.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do

      def setup_tag(_, ctx), do: {:ok, ctx}
      defoverridable [setup_tag: 2]

    end
  end

  @doc """
  Creates a new test context by applying
  the provided context to setup_tag functions
  selected by the test or module tags.

  Returns {:ok, new_context}
  """
  def setup(tags = %{case: module}, context) do
    {:ok, Enum.reduce(tags, context,
        &setup_tag(module, &1, &2))}
  end

  defp setup_tag(module, {name, true}, context) do
    if setup_tag?(name) do
      setup_tag(module, {name, {module, [{name, []}]}}, context)
    else
      context
    end
  end

  defp setup_tag(_, {name, module}, context) when is_atom(module) do
    if setup_tag?(name) do
      setup_tag(module, {name, {module, [{name, []}]}}, context)
    else
      context
    end
  end

  defp setup_tag(_, {name, {module, [{fname, args}]}}, context) do
    {:ok, new_context} = apply(module, fname, [context] ++ args)
    new_context
  end

  defp setup_tag(module, tag, context) do
    {:ok, new_context} = apply(module, :setup_tag, [tag, context])
    new_context
  end

  defp setup_tag?(name) do
    Atom.to_string(name) |> String.starts_with?("setup_")
  end
end
