# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Mix.Tasks.Liberator.Chart do
  @shortdoc "Generates source text for a chart of Liberator's decision tree"

  @moduledoc """
  Generates source text for a decision tree chart for a Liberator resource.
  The chart is compatible with the [Graphviz](https://graphviz.org/) graph visualization software.

  ```sh
  mix liberator.chart
  ```

  By default, this function will print the default decision tree to standard output.
  This task can also take a module argument for any module that `use`s `Liberator.Resource`,
  in which case the decision tree for the given module will be printed.

  ```sh
  mix liberator.chart MyApp.MyResource
  ```

  You can also provide the `--output` or `-o` option to print the chart source to a file.

  ```sh
  mix liberator.chart -o myresource.dot MyApp.MyResource
  ```

  ## Generating a chart with the returned source code

  Unfortunately, there's not a Graphviz binding for Elixir.
  If you want to create an actual image of your chart,
  you will have to install [Graphviz](https://graphviz.org/),
  or use one of its language bindings for another language.

  Once you have installed Graphviz, you can run a command like the following to generate an image

  ```sh
  dot myresource.dot -Tsvg -o myresource.svg
  ```
  """

  use Mix.Task

  def run(args) do
    {opts, argv, _errors} =
      OptionParser.parse(args, aliases: [o: :output], strict: [output: :string])

    if length(argv) > 1 do
      IO.puts(:stderr, "More than one module name given, ignoring all after the first")
    end

    base_module =
      if Enum.empty?(argv) do
        Liberator.Default.DecisionTree
      else
        "Elixir.#{List.first(argv)}"
        |> String.to_existing_atom()
      end

    Code.ensure_loaded(base_module)

    unless function_exported?(base_module, :decisions, 0) and
             function_exported?(base_module, :actions, 0) and
             function_exported?(base_module, :handlers, 0) do
      raise "The given module, #{base_module}, does not implement " <>
              "the required functions from Liberator.Resource. " <>
              "Make sure that module has `use Liberator.Resource` in it."
    end

    chart = dot(base_module)

    if filename = Keyword.get(opts, :output) do
      File.write!(filename, chart)
      IO.puts("Chart saved to #{filename}")
    else
      IO.puts(chart)
    end
  end

  defp dot(base_module) do
    handler_rank_group =
      base_module.handlers()
      |> Map.keys()
      |> Enum.map_join(" ", fn handler ->
        ~s("#{handler}")
      end)

    handler_shapes =
      base_module.handlers()
      |> Map.keys()
      |> Enum.flat_map(fn handler ->
        [
          ~s("#{handler}" [shape=box])
        ]
      end)
      |> Enum.join("\n")

    decisions =
      base_module.decisions()
      |> Enum.flat_map(fn {decision_fn, {true_step, false_step}} ->
        [
          ~s("#{decision_fn}" -> "#{true_step}" [label="yes"]),
          ~s("#{decision_fn}" -> "#{false_step}" [label="no"])
        ]
      end)
      |> Enum.join("\n")

    actions =
      base_module.actions()
      |> Enum.flat_map(fn {action, after_action} ->
        [
          ~s("#{action}" [shape=box]),
          ~s("#{action}" -> "#{after_action}")
        ]
      end)
      |> Enum.join("\n")

    """
    strict digraph G {
      { rank=same #{handler_rank_group}}
      #{handler_shapes}
      #{decisions}
      #{actions}
    }
    """
  end
end
