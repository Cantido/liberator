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
    test "returns true if the accept header is */*" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "*/*")

      assert Base.accept_exists?(conn)
    end
    test "returns false if the accept header is not present" do
      assert not Base.accept_exists?(conn(:get, "/"))
    end
  end

  describe "accept_language_exists?/1" do
    test "returns true if the accept-language header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "en")

      assert Base.accept_language_exists?(conn)
    end
    test "returns false if the accept-language header is not present" do
      assert not Base.accept_language_exists?(conn(:get, "/"))
    end
  end

  describe "accept_charset_exists?/1" do
    test "returns true if the accept-charset header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-charset", "en")

      assert Base.accept_charset_exists?(conn)
    end
    test "returns false if the accept-charset header is not present" do
      assert not Base.accept_charset_exists?(conn(:get, "/"))
    end
  end

  describe "accept_encoding_exists?/1" do
    test "returns true if the accept-encoding header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-encoding", "en")

      assert Base.accept_encoding_exists?(conn)
    end
    test "returns false if the accept-encoding header is not present" do
      assert not Base.accept_encoding_exists?(conn(:get, "/"))
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

  describe "if_modified_since_exists?" do
    test "returns true if the if-modified-since header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", "*")

      assert Base.if_modified_since_exists?(conn)
    end
    test "returns false if the if-modified-since header is not present" do
      assert not Base.if_modified_since_exists?(conn(:get, "/"))
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

  describe "if_modified_since_valid_date?" do
    test "returns true if if_modified_since header contains a valid date" do
      {:ok, time_str} =
        Timex.now()
        |> Timex.Format.DateTime.Formatters.Strftime.format("%a, %d20 %b %Y %H:%M:%S GMT")
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", time_str)

      assert Base.if_modified_since_valid_date?(conn)
    end
    test "returns false if if_modified_since header contains an invalid date" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", "asdf")

      assert not Base.if_modified_since_valid_date?(conn)
    end
  end

  describe "if_unmodified_since_exists?" do
    test "returns true if the if-unmodified-since header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", "*")

      assert Base.if_unmodified_since_exists?(conn)
    end
    test "returns false if the if-unmodified-since header is not present" do
      assert not Base.if_unmodified_since_exists?(conn(:get, "/"))
    end
  end

  describe "if_unmodified_since_valid_date?" do
    test "returns true if if_unmodified_since header contains a valid date" do
      {:ok, time_str} =
        Timex.now()
        |> Timex.Format.DateTime.Formatters.Strftime.format("%a, %d20 %b %Y %H:%M:%S GMT")
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", time_str)

      assert Base.if_unmodified_since_valid_date?(conn)
    end
    test "returns false if if_unmodified_since header contains an invalid date" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", "asdf")

      assert not Base.if_unmodified_since_valid_date?(conn)
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

  describe "if_match_exists?" do
    test "returns true if the if-match header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "*")

      assert Base.if_match_exists?(conn)
    end
    test "returns false if the if-match header is not present" do
      assert not Base.if_match_exists?(conn(:get, "/"))
    end
  end

  describe "if_match_star?" do
    test "returns true if the if-match * header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "*")

      assert Base.if_match_star?(conn)
    end
    test "returns false if the if-match * header is not present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "abcdefg")

      assert not Base.if_match_star?(conn)
    end
  end
end
