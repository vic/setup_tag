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
      setup(context) do
        unquote(__MODULE__).setup(context)
      end
    end
  end

  def setup(context = %{case: module}) do
    setup(module, context)
  end

  defp setup(module, context) do
    {:ok, Enum.reduce(context, context, &maybe_setup(module, &1, &2))}
  end

  defp maybe_setup(module, {name, value}, context) do
    if is_atom(name) and String.starts_with?("#{name}", "setup") do
      {:ok, new_context} = do_setup(module, name, value, context)
      new_context
    else
      context
    end
  end

  defp maybe_setup(_module, _, context), do: context

  defp do_setup(module, _tag_name, setup, context) when is_atom(setup) do
    apply(module, setup, [context])
  end

  defp do_setup(_module, _tag_name, func, context) when is_function(func) do
    func.(context)
  end

  defp do_setup(module, _tag_name, funs, context) when is_list(funs) do
    {:ok, Enum.reduce(funs, context, &seq_setup(module, &1, &2))}
  end

  defp seq_setup(_module, fun, context) when is_function(fun) do
    {:ok, new_context} = fun.(context)
    new_context
  end

  defp seq_setup(module, fun, context) when is_atom(fun) do
    {:ok, new_context} = apply(module, fun, [context])
    new_context
  end

  defp seq_setup(module, {name, value}, context) when is_binary(value) do
    seq_setup(module, {name, [value]}, context)
  end

  defp seq_setup(module, {name, value}, context) when not is_list(value) do
    seq_setup(module, {name, [value]}, context)
  end

  defp seq_setup(_module, {fun, args}, context) when is_function(fun) do
    {:ok, new_context} = apply(fun, [context] ++ args)
    new_context
  end

  defp seq_setup(module, {name, args}, context) do
    {:ok, new_context} = apply(module, name, [context] ++ args)
    new_context
  end
end
