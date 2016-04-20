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
    context = context
    |> Enum.filter_map(&setup_tag?/1, &setup_fn/1)
    |> List.flatten
    |> Enum.reduce(context, fn setup, context ->
      {:ok, new_context} = setup_run(module, setup, context)
      new_context
    end)
    {:ok, context}
  end

  defp setup_tag?({k, _v}) do
    String.starts_with?("#{k}", "setup")
  end

  defp setup_fn({_k, v}), do: v

  defp setup_run(module, name, context) when not is_tuple(name) do
    setup_run(module, {name, []}, context)
  end

  defp setup_run(module, {name}, context) do
    setup_run(module, {name, []}, context)
  end

  defp setup_run(module, {name, args}, context) when not is_list(args) do
    setup_run(module, {name, [args]}, context)
  end

  defp setup_run(module, {name, args}, context) when is_atom(name) do
    apply(module, name, [context] ++ args)
  end

  defp setup_run(_module, {fun, args}, context) when is_function(fun) do
    apply(fun, [context] ++ args)
  end

  defp setup_run(module, {name, args, attr}, context) when not is_list(attr) or is_binary(attr) do
    setup_run(module, {name, args, [attr]}, context)
  end

  defp setup_run(module, {name, args, attr}, context) do
    value = setup_run(module, {name, args}, context)
    {:ok, put_in(context, attr, value)}
  end


end

