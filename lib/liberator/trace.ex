# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Liberator.Trace do
  import Plug.Conn
  require Logger

  @moduledoc """
  Decision tracing functions.
  """

  @doc """
  Get the log of all decisions made on the given conn.

  The trace is a list of maps, each map corresponding to one call to a decision function.
  Each map has the following keys:

  - `:step`: the name of the function that was executed, or the atoms `:start` or `:stop`
  - `:result`: the value the function returned
  - `:timestamp`: the time the function was called
  - `:duration`: how long the call took, in native time units

  """
  @doc since: "1.1"
  def get_trace(conn) do
    Map.get(conn.private, :liberator_trace, [])
  end

  @doc false
  def start(conn, start_time) do
    first_trace = [
      %{
        step: :start,
        timestamp: start_time
      }
    ]

    put_private(conn, :liberator_trace, first_trace)
  end

  @doc false
  def update_trace(conn, next_step, result, called_at, duration) do
    current_trace = get_trace(conn)

    updated_trace =
      current_trace ++
        [
          %{
            step: next_step,
            result: result,
            timestamp: called_at,
            duration: duration
          }
        ]

    put_private(conn, :liberator_trace, updated_trace)
  end

  @doc false
  def stop(conn, end_time) do
    current_trace = get_trace(conn)

    updated_trace =
      current_trace ++
        [
          %{
            step: :stop,
            timestamp: end_time
          }
        ]

    put_private(conn, :liberator_trace, updated_trace)
  end

  @doc """
  Get a list of tuples for the `x-liberator-trace` header,
  based on the given trace.
  """
  @doc since: "1.3"
  def headers(trace) do
    trace
    # remove :start and :stop traces
    |> Enum.slice(1, Enum.count(trace) - 2)
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
      # remove :start and :stop traces
      |> Enum.slice(1, Enum.count(trace) - 2)
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {%{step: key, duration: duration_native} = trace, index} ->
        val = Map.get(trace, :result, nil)
        duration_us = System.convert_time_unit(duration_native, :native, :microsecond)
        "    #{index + 1}. #{Atom.to_string(key)}: #{inspect(val)} (took #{duration_us} µs)"
      end)

    header =
      if request_id do
        "Liberator trace for request #{inspect(request_id)} to #{request_path}:\n\n"
      else
        "Liberator trace for request to #{request_path}:\n\n"
      end

    Logger.debug(header <> trace)
  end
end
