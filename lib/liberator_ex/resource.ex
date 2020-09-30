defmodule LiberatorEx.Resource do
  import Plug.Conn
  @moduledoc """
  Documentation for LiberatorEx.Resource.
  """

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    conn
    |> send_resp(200, Jason.encode!([]))
  end
end
