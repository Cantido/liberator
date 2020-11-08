defmodule Mix.Tasks.Chart do
  use Mix.Task

  @shortdoc "Generates source text for a flow chart of Liberator's decision tree"
  def run(args) do
    {opts, argv, _errors} = OptionParser.parse(args, aliases: [o: :output], strict: [output: :string])

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

    unless function_exported?(base_module, :decisions, 0) and
           function_exported?(base_module, :actions, 0) and
           function_exported?(base_module, :handlers, 0) do
      raise "The given module, #{List.first(argv)}, does not implement " <>
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
      |> Enum.map(fn handler ->
        ~s("#{handler}")
      end)
      |> Enum.join(" ")

    handler_shapes =
      base_module.handlers()
      |> Map.keys()
      |> Enum.flat_map(fn handler ->
        [
          ~s("#{handler}" [shape=box]),
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
