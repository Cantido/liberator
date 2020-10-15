defmodule Liberator.Conn do
  import Plug.Conn

  @moduledoc """
  Utility functions for dealing with `Plug.Conn` structs.
  """

  @doc """
  Reads the body from the conn, and puts it in the assigns under the key `:raw_body`.

  Reading the body of a request takes more steps than you may think.
  """
  def read_body(%Plug.Conn{} = conn) do
    {body, conn} =
      Stream.repeatedly(fn -> Plug.Conn.read_body(conn) end)
      |> Enum.reduce_while([], fn {{key, body, conn}, {body_so_far, _conn}} ->
        case key do
          :more -> {:cont, {body_so_far <> body, conn}}
          :ok ->   {:halt, {body_so_far <> body, conn}}
      end)
    assign(conn, :raw_body, body)
  end
end
