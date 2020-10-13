defmodule Liberator.Trace do
  import Plug.Conn
  require Logger

  @moduledoc """
  Decision tracing functions.
  """

  @doc """
  Get the log of all decisions made on the given conn.
  """
  def get_trace(conn) do
    Map.get(conn.private, :liberator_trace, [])
  end

  @doc false
  def update_trace(conn, next_step, result) do
    current_trace = get_trace(conn)
    updated_trace = current_trace ++ [{next_step, result}]

    put_private(conn, :liberator_trace, updated_trace)
  end

  def log(trace, request_path, request_id) do
    trace =
      trace
      |> Enum.with_index()
      |> Enum.map(fn {{key, val}, index} ->
        "    #{index + 1}. #{Atom.to_string(key)}: #{inspect(val)}"
      end)
      |> Enum.join("\n")

    header =
      if request_id do
        "Liberator trace for request #{inspect(request_id)} to #{request_path}:\n\n"
      else
        "Liberator trace for request to #{request_path}:\n\n"
      end

    Logger.debug(header <> trace)
  end
end
