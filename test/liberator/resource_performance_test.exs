defmodule Liberator.ResourcePerformanceTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @tag :skip
  test "performance" do
    defmodule PerformanceTracingResource do
      use Liberator.Resource
    end

    conn = conn(:get, "/", "hello!") |> put_req_header("content-type", "text/plain")

    conn = PerformanceTracingResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"

    trace = conn.private.liberator_trace

    {[start], rest} = Enum.split(trace, 1)

    {step_latency_results, _end_time} =
      Enum.map_reduce(rest, start.timestamp, fn %{step: step_name, timestamp: start_timestamp},
                                                previous_timestamp ->
        step_duration = Timex.diff(start_timestamp, previous_timestamp, :microseconds)

        {{step_name, step_duration}, start_timestamp}
      end)

    Enum.each(step_latency_results, fn {step_name, step_duration} ->
      IO.puts("Before #{inspect(step_name)}: #{step_duration} µs")
    end)

    decision_traces = Enum.slice(trace, 1, Enum.count(trace) - 2)

    Enum.each(decision_traces, fn %{step: step_name, duration: step_duration} ->
      duration_us = System.convert_time_unit(step_duration, :native, :nanosecond)
      IO.puts("Step #{inspect(step_name)}: #{duration_us} ns")
    end)
  end
end
