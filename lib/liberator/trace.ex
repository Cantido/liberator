defmodule Liberator.Trace do
  import Plug.Conn
  require Logger

  @moduledoc """
  Decision tracing functions.
  """

  @doc """
  Get the log of all decisions made on the given conn.
  """
  @doc since: "1.1"
  def get_trace(conn) do
    Map.get(conn.private, :liberator_trace, [])
  end

  @doc false
  def update_trace(conn, next_step, result, duration) do
    current_trace = get_trace(conn)
    updated_trace = current_trace ++ [%{
      step: next_step,
      result: result,
      duration: duration
    }]

    put_private(conn, :liberator_trace, updated_trace)
  end

  @doc """
  Get a list of tuples for the `x-liberator-trace` header,
  based on the given trace.
  """
  @doc since: "1.3"
  def headers(trace) do
    trace
    |> Enum.map(fn %{step: key, result: val, duration: duration_native} ->
      duration_us = System.convert_time_unit(duration_native, :native, :microsecond)

      {"x-liberator-trace", "#{Atom.to_string(key)}: #{inspect(val)} (took #{duration_us} µs)"}
    end)
  end

  @doc """
  Log a message containing the given trace,
  along with its request path and optional request ID.
  """
  @doc since: "1.3"
  def log(trace, request_path, request_id \\ nil) do
    trace =
      trace
      |> Enum.with_index()
      |> Enum.map(fn {%{step: key, result: val, duration: duration_native}, index} ->
        duration_us = System.convert_time_unit(duration_native, :native, :microsecond)
        "    #{index + 1}. #{Atom.to_string(key)}: #{inspect(val)} (took #{duration_us} µs)"
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
