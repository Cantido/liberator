defmodule Liberator.ContentNegotiation do
  import Plug.Conn

  @moduledoc false

  def accept_something(conn, key, header_name, available_values) do
    val =
      available_values
      |> Enum.zip(get_req_header(conn, header_name))
      |> Enum.filter(fn {av, req} -> String.starts_with?(req, av) or "*" in available_values end)
      |> Enum.map(fn {_av, req} -> req end)
      |> Enum.take(1)
      |> Map.new(fn c -> {key, c} end)

    if Enum.any?(val) do
      val
    else
      false
    end
  end
end
