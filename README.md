# SetupTag

SetupTag allows you to create a test context by easily mix and match
test setup functions selected by the tags applied to your test or module.

Well, it's actually a feature of ExUnit, but this module lets you
reuse and mix functions over different modules.

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add setup_tag to your list of dependencies in `mix.exs`:

        def deps do
          [{:setup_tag, "~> 0.0.1"}]
        end

## Usage

See setup_tag_test.exs for example usage.
