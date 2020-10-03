defmodule Liberator.Trace do
  import Plug.Conn
  
  def get_trace(conn) do
    Map.get(conn.private, :liberator_trace, [])
  end

  def update_trace(conn, next_step, result) do
    current_trace = get_trace(conn)
    updated_trace = current_trace ++ [{next_step, result}]

    put_private(conn, :liberator_trace, updated_trace)
  end
end
