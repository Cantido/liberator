defmodule Liberator.ContentNegotiation do
  import Plug.Conn
  @moduledoc false

  def accept_something(conn, key, header_name, available_values) do
    vals =
      get_req_header(conn, header_name)
      |> Enum.flat_map(&String.split(&1, ","))
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn hdr ->
        case String.split(hdr, ";") do
          [type] -> {type, %{"q" => "1.0"}}
          [type | params] -> {type, parse_params(params)}
        end
      end)
      |> product(available_values)
      |> Enum.filter(fn {{req, _params}, av} ->
        req == av or "*" in available_values
      end)
      |> Enum.map(fn {req, _av} -> req end)

    if Enum.any?(vals) do
      {type, _params} =
        Enum.max_by(vals, fn {_type, params} ->
          params
          |> Map.get("q", "1.0")
          |> Float.parse()
          |> case do
            {q, ""} -> q
            _ -> 0.0
          end
        end)
      Map.new([{key, type}])
    else
      false
    end
  end

  defp parse_params(params) do
    params
    |> Enum.map(&parse_param/1)
    |> Map.new()
  end

  defp parse_param(param) do
    param
    |> String.split("=")
    |> case do
      [param, val] -> {param, val}
    end
  end

  defp product(a, b) do
    Enum.flat_map(a, fn i ->
      Enum.map(b, fn j ->
        {i, j}
      end)
    end)
  end
end
