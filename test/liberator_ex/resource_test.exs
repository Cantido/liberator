defmodule LiberatorEx.ResourceTest do
  use ExUnit.Case
  use Plug.Test
  alias LiberatorEx.Resource
  doctest LiberatorEx.Resource

  @opts Resource.init([])

  test "gets index" do
    conn = conn(:get, "/")

    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == []
  end
end
