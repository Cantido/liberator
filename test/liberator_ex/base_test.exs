defmodule LiberatorEx.BaseTest do
  use ExUnit.Case
  use Plug.Test
  alias LiberatorEx.Base
  doctest LiberatorEx.Base

  describe "method_allowed?/1" do
    test "allows GET" do
      assert Base.method_allowed?(conn(:get, "/"))
    end

    test "allows HEAD" do
      assert Base.method_allowed?(conn(:get, "/"))
    end

    test "allows PUT" do
      assert Base.method_allowed?(conn(:get, "/"))
    end

    test "allows POST" do
      assert Base.method_allowed?(conn(:get, "/"))
    end

    test "allows DELETE" do
      assert Base.method_allowed?(conn(:get, "/"))
    end

    test "allows OPTIONS" do
      assert Base.method_allowed?(conn(:get, "/"))
    end

    test "allows TRACE" do
      assert Base.method_allowed?(conn(:get, "/"))
    end

    test "allows PATCH" do
      assert Base.method_allowed?(conn(:get, "/"))
    end

    test "disallows asdf" do
      assert not Base.method_allowed?(conn(:asdf, "/"))
    end
  end

  describe "media_type_available?/1" do
    test "allows text/plain" do
      assert Base.media_type_available?(conn(:get, "/") |> put_req_header("accept", "text/plain"))
    end
    test "disallows text/nonexistent-media-type" do
      assert not Base.media_type_available?(conn(:get, "/") |> put_req_header("accept", "text/nonexistent-media-type"))
    end
  end

end
