defmodule Mix.Tasks.Chart do
  use Mix.Task

  @shortdoc "Generates source text for a flow chart of Liberator's decision tree"
  def run(args) do
    {opts, _argv, _errors} = OptionParser.parse(args, aliases: [o: :output], strict: [output: :string])

    chart = dot()

    if filename = Keyword.get(opts, :output) do
      File.write!(filename, chart)
      IO.puts("Chart saved to #{filename}")
    else
      IO.puts(chart)
    end
  end

  def dot do
    handler_rank_group =
      Liberator.Evaluator.handlers()
      |> Map.keys()
      |> Enum.map(fn handler ->
        ~s("#{handler}")
      end)
      |> Enum.join(" ")

    handler_shapes =
      Liberator.Evaluator.handlers()
      |> Map.keys()
      |> Enum.flat_map(fn handler ->
        [
          ~s("#{handler}" [shape=box]),
        ]
      end)
      |> Enum.join("\n")

    decisions =
      Liberator.Evaluator.decisions()
      |> Enum.flat_map(fn {decision_fn, {true_step, false_step}} ->
        [
          ~s("#{decision_fn}" -> "#{true_step}" [label="yes"]),
          ~s("#{decision_fn}" -> "#{false_step}" [label="no"])
        ]
      end)
      |> Enum.join("\n")

    actions =
      Liberator.Evaluator.actions()
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
