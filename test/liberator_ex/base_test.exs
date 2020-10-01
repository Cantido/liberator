defmodule LiberatorEx.BaseTest do
  use ExUnit.Case
  use Plug.Test
  use Timex
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

  describe "is_options?" do
    test "returns true for options type" do
      assert Base.is_options?(conn(:options, "/"))
    end

    test "returns false for non-options type" do
      assert not Base.is_options?(conn(:get, "/"))
    end
  end

  describe "method_put?" do
    test "returns true for put type" do
      assert Base.method_put?(conn(:put, "/"))
    end

    test "returns false for non-put type" do
      assert not Base.method_put?(conn(:get, "/"))
    end
  end

  describe "method_post?" do
    test "returns true for post type" do
      assert Base.method_post?(conn(:post, "/"))
    end

    test "returns false for non-post type" do
      assert not Base.method_post?(conn(:get, "/"))
    end
  end

  describe "method_delete?" do
    test "returns true for delete type" do
      assert Base.method_delete?(conn(:delete, "/"))
    end

    test "returns false for non-delete type" do
      assert not Base.method_delete?(conn(:get, "/"))
    end
  end

  describe "method_patch?" do
    test "returns true for patch type" do
      assert Base.method_patch?(conn(:patch, "/"))
    end

    test "returns false for non-patch type" do
      assert not Base.method_patch?(conn(:get, "/"))
    end
  end

  describe "accept_exists?/1" do
    test "returns true if the accept header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "application/json")

      assert Base.accept_exists?(conn)
    end
      test "returns false if the accept header is not present" do
        assert not Base.accept_exists?(conn(:get, "/"))
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

  describe "modified_since?" do
    test "returns true if last modification date is after modification_since" do
      {:ok, time_str} =
        Timex.Timezone.get("GMT")
        |> Timex.now()
        |> Timex.shift(days: -1)
        |> Timex.Format.DateTime.Formatters.Strftime.format("%a, %d20 %b %Y %H:%M:%S GMT")
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", time_str)

      assert Base.modified_since?(conn)
    end
    test "returns false if last modification date is before modification_since" do
      {:ok, time_str} =
        Timex.Timezone.get("GMT")
        |> Timex.now()
        |> Timex.shift(days: 1)
        |> Timex.Format.DateTime.Formatters.Strftime.format("%a, %d20 %b %Y %H:%M:%S GMT")
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", time_str)

      assert not Base.modified_since?(conn)
    end
  end

  describe "unmodified_since?" do
    test "returns false if last modification date is after modification_since" do
      {:ok, time_str} =
        Timex.Timezone.get("GMT")
        |> Timex.now()
        |> Timex.shift(days: -1)
        |> Timex.Format.DateTime.Formatters.Strftime.format("%a, %d20 %b %Y %H:%M:%S GMT")
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", time_str)

      assert not Base.unmodified_since?(conn)
    end
    test "returns true if last modification date is before modification_since" do
      {:ok, time_str} =
        Timex.Timezone.get("GMT")
        |> Timex.now()
        |> Timex.shift(days: 1)
        |> Timex.Format.DateTime.Formatters.Strftime.format("%a, %d20 %b %Y %H:%M:%S GMT")
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", time_str)

      assert Base.unmodified_since?(conn)
    end
  end

end
