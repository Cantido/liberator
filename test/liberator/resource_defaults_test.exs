# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.ResourceDefaultsTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Liberator.HTTPDateTime

  defmodule MyDefaultResource do
    use Liberator.Resource
  end

  describe "method_allowed?/1" do
    test "allows GET" do
      assert MyDefaultResource.method_allowed?(conn(:get, "/"))
    end

    test "allows HEAD" do
      assert MyDefaultResource.method_allowed?(conn(:get, "/"))
    end

    test "allows PUT" do
      assert MyDefaultResource.method_allowed?(conn(:get, "/"))
    end

    test "allows POST" do
      assert MyDefaultResource.method_allowed?(conn(:get, "/"))
    end

    test "allows DELETE" do
      assert MyDefaultResource.method_allowed?(conn(:get, "/"))
    end

    test "allows OPTIONS" do
      assert MyDefaultResource.method_allowed?(conn(:get, "/"))
    end

    test "allows TRACE" do
      assert MyDefaultResource.method_allowed?(conn(:get, "/"))
    end

    test "allows PATCH" do
      assert MyDefaultResource.method_allowed?(conn(:get, "/"))
    end

    test "disallows asdf" do
      refute MyDefaultResource.method_allowed?(conn(:asdf, "/"))
    end
  end

  describe "method_options?" do
    test "returns true for options type" do
      assert MyDefaultResource.method_options?(conn(:options, "/"))
    end

    test "returns false for non-options type" do
      refute MyDefaultResource.method_options?(conn(:get, "/"))
    end
  end

  describe "method_put?" do
    test "returns true for put type" do
      assert MyDefaultResource.method_put?(conn(:put, "/"))
    end

    test "returns false for non-put type" do
      refute MyDefaultResource.method_put?(conn(:get, "/"))
    end
  end

  describe "method_post?" do
    test "returns true for post type" do
      assert MyDefaultResource.method_post?(conn(:post, "/"))
    end

    test "returns false for non-post type" do
      refute MyDefaultResource.method_post?(conn(:get, "/"))
    end
  end

  describe "method_delete?" do
    test "returns true for delete type" do
      assert MyDefaultResource.method_delete?(conn(:delete, "/"))
    end

    test "returns false for non-delete type" do
      refute MyDefaultResource.method_delete?(conn(:get, "/"))
    end
  end

  describe "method_patch?" do
    test "returns true for patch type" do
      assert MyDefaultResource.method_patch?(conn(:patch, "/"))
    end

    test "returns false for non-patch type" do
      refute MyDefaultResource.method_patch?(conn(:get, "/"))
    end
  end

  describe "body_exists?/1" do
    test "returns true if the body is present" do
      conn = conn(:get, "/", "test body") |> put_req_header("content-type", "text/plain")
      assert MyDefaultResource.body_exists?(conn)
    end

    test "returns false if the body is not present" do
      refute MyDefaultResource.body_exists?(conn(:get, "/"))
    end
  end

  describe "accept_exists?/1" do
    test "returns true if the accept header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "application/json")

      assert MyDefaultResource.accept_exists?(conn)
    end

    test "returns true if the accept header is */*" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "*/*")

      assert MyDefaultResource.accept_exists?(conn)
    end

    test "returns false if the accept header is not present" do
      refute MyDefaultResource.accept_exists?(conn(:get, "/"))
    end
  end

  describe "accept_language_exists?/1" do
    test "returns true if the accept-language header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "en")

      assert MyDefaultResource.accept_language_exists?(conn)
    end

    test "returns false if the accept-language header is not present" do
      refute MyDefaultResource.accept_language_exists?(conn(:get, "/"))
    end
  end

  defmodule LanguageAgnosticResource do
    use Liberator.Resource
    def available_languages(_conn), do: ["*"]
  end

  defmodule EnglishOnlyResource do
    use Liberator.Resource
    def available_languages(_conn), do: ["en"]
  end

  defmodule GermanOnlyResource do
    use Liberator.Resource
    def available_languages(_conn), do: ["de"]
  end

  describe "language_available?/1" do
    test "returns the user's requested language if acceptable languges is *" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "de")

      assert LanguageAgnosticResource.language_available?(conn) == %{language: "de"}
    end

    test "returns * if the user accepts * and only * is available" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "*")

      assert LanguageAgnosticResource.language_available?(conn) == %{language: "*"}
    end

    test "returns false if acceptable languges is different from requested language" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "de")

      refute EnglishOnlyResource.language_available?(conn)
    end

    test "returns a map containing the matching language" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "en")

      assert EnglishOnlyResource.language_available?(conn) == %{language: "en"}
    end

    test "sets the Gettext locale to the given locale when it is available" do
      # Using the GermanOnlyResource here just in case my default language is set to "en".
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "de")

      GermanOnlyResource.language_available?(conn)

      assert Gettext.get_locale() == "de"
    end

    test "does not set the Gettext locale if language is *" do
      # The best I can do is assert that Gettext.get_locale() is "en",
      # because it always returns the default locale if one isn't set
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "*")

      LanguageAgnosticResource.language_available?(conn)

      assert Gettext.get_locale() == "en"
    end
  end

  describe "accept_charset_exists?/1" do
    test "returns true if the accept-charset header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-charset", "en")

      assert MyDefaultResource.accept_charset_exists?(conn)
    end

    test "returns false if the accept-charset header is not present" do
      refute MyDefaultResource.accept_charset_exists?(conn(:get, "/"))
    end
  end

  describe "accept_encoding_exists?/1" do
    test "returns true if the accept-encoding header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-encoding", "en")

      assert MyDefaultResource.accept_encoding_exists?(conn)
    end

    test "returns false if the accept-encoding header is not present" do
      refute MyDefaultResource.accept_encoding_exists?(conn(:get, "/"))
    end
  end

  defmodule Utf8EncodingAvailableResource do
    use Liberator.Resource

    def available_encodings(_), do: ["UTF-8"]
  end

  describe "encoding_available?/1" do
    test "disallows UTF-16" do
      refute Utf8EncodingAvailableResource.encoding_available?(
               conn(:get, "/")
               |> put_req_header("accept-encoding", "UTF-16")
             )
    end

    test "returns a map containing the matching encoding" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-encoding", "UTF-8")

      assert Utf8EncodingAvailableResource.encoding_available?(conn) == %{encoding: "UTF-8"}
    end
  end

  defmodule JsonMediaTypeAvailableResource do
    use Liberator.Resource

    def available_media_types(_), do: ["application/json", "text/html"]
  end

  describe "media_type_available?/1" do
    test "disallows text/nonexistent-media-type" do
      refute MyDefaultResource.media_type_available?(
               conn(:get, "/")
               |> put_req_header("accept", "text/nonexistent-media-type")
             )
    end

    test "returns a map containing the matching media type" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "application/json")

      assert JsonMediaTypeAvailableResource.media_type_available?(conn) == %{
               media_type: "application/json"
             }
    end

    test "returns a map containing the matching media type with the highest q" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "application/json;q=1.0, text/html;q=0.8")

      assert JsonMediaTypeAvailableResource.media_type_available?(conn) == %{
               media_type: "application/json"
             }
    end

    test "returns a map containing the matching media type with the highest q even if they're out of order" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "text/html;q=0.8, application/json;q=1.0")

      assert JsonMediaTypeAvailableResource.media_type_available?(conn) == %{
               media_type: "application/json"
             }
    end

    test "values with plus modifiers aren't the same" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "text/html;q=0.8, application/json+myspecialschema;q=1.0")

      assert JsonMediaTypeAvailableResource.media_type_available?(conn) == %{
               media_type: "text/html"
             }
    end

    test "values with no q are the highest ranked" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "text/html;q=0.8, application/json")

      assert JsonMediaTypeAvailableResource.media_type_available?(conn) == %{
               media_type: "application/json"
             }
    end
  end

  defmodule CharsetUtf8AvailableResource do
    use Liberator.Resource

    def available_charsets(_), do: ["UTF-8"]
  end

  defmodule CharsetUtf16UnavailableResource do
    use Liberator.Resource

    def available_charsets(_), do: ["UTF-8"]
  end

  defmodule SetsCharsetResource do
    use Liberator.Resource

    def available_charsets(_), do: ["UTF-8"]
  end

  describe "charset_available?/1" do
    test "returns true if charset is present in `available_charsets/1`" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-charset", "UTF-8")

      assert CharsetUtf8AvailableResource.charset_available?(conn)
    end

    test "returns trfalseue if charset is not present in `available_charsets/1`" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-charset", "UTF-16")

      refute CharsetUtf16UnavailableResource.charset_available?(conn)
    end

    test "returns a map containing the matching charset" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-charset", "UTF-8")

      assert SetsCharsetResource.charset_available?(conn) == %{charset: "UTF-8"}
    end
  end

  describe "if_modified_since_exists?" do
    test "returns true if the if-modified-since header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", "*")

      assert MyDefaultResource.if_modified_since_exists?(conn)
    end

    test "returns false if the if-modified-since header is not present" do
      refute MyDefaultResource.if_modified_since_exists?(conn(:get, "/"))
    end
  end

  describe "modified_since?" do
    test "returns true if last modification date is after modification_since" do
      time_str =
        Timex.Timezone.get("GMT")
        |> Timex.now()
        |> Timex.shift(days: -1)
        |> HTTPDateTime.format!()

      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", time_str)

      assert MyDefaultResource.modified_since?(conn)
    end

    test "returns false if last modification date is before modification_since" do
      time_str =
        Timex.Timezone.get("GMT")
        |> Timex.now()
        |> Timex.shift(days: 1)
        |> HTTPDateTime.format!()

      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", time_str)

      refute MyDefaultResource.modified_since?(conn)
    end
  end

  describe "if_modified_since_valid_date?" do
    test "returns true if if_modified_since header contains a valid date" do
      time_str =
        Timex.now()
        |> HTTPDateTime.format!()

      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", time_str)

      assert MyDefaultResource.if_modified_since_valid_date?(conn)
    end

    test "returns false if if_modified_since header contains an invalid date" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", "asdf")

      refute MyDefaultResource.if_modified_since_valid_date?(conn)
    end
  end

  describe "if_unmodified_since_exists?" do
    test "returns true if the if-unmodified-since header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", "*")

      assert MyDefaultResource.if_unmodified_since_exists?(conn)
    end

    test "returns false if the if-unmodified-since header is not present" do
      refute MyDefaultResource.if_unmodified_since_exists?(conn(:get, "/"))
    end
  end

  describe "if_unmodified_since_valid_date?" do
    test "returns true if if_unmodified_since header contains a valid date" do
      time_str =
        Timex.now()
        |> HTTPDateTime.format!()

      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", time_str)

      assert MyDefaultResource.if_unmodified_since_valid_date?(conn)
    end

    test "returns false if if_unmodified_since header contains an invalid date" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", "asdf")

      refute MyDefaultResource.if_unmodified_since_valid_date?(conn)
    end
  end

  describe "unmodified_since?" do
    test "returns false if last modification date is after modification_since" do
      time_str =
        Timex.Timezone.get("GMT")
        |> Timex.now()
        |> Timex.shift(days: -1)
        |> HTTPDateTime.format!()

      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", time_str)

      refute MyDefaultResource.unmodified_since?(conn)
    end

    test "returns true if last modification date is before modification_since" do
      time_str =
        Timex.Timezone.get("GMT")
        |> Timex.now()
        |> Timex.shift(days: 1)
        |> HTTPDateTime.format!()

      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", time_str)

      assert MyDefaultResource.unmodified_since?(conn)
    end
  end

  describe "if_match_exists?" do
    test "returns true if the if-match header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "*")

      assert MyDefaultResource.if_match_exists?(conn)
    end

    test "returns false if the if-match header is not present" do
      refute MyDefaultResource.if_match_exists?(conn(:get, "/"))
    end
  end

  describe "if_match_star?" do
    test "returns true if the if-match * header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "*")

      assert MyDefaultResource.if_match_star?(conn)
    end

    test "returns false if the if-match * header is not present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "abcdefg")

      refute MyDefaultResource.if_match_star?(conn)
    end
  end

  describe "if_match_star_exists_for_missing?" do
    test "returns true if the if-match * header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "*")

      assert MyDefaultResource.if_match_star_exists_for_missing?(conn)
    end

    test "returns false if the if-match * header is not present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "abcdefg")

      refute MyDefaultResource.if_match_star_exists_for_missing?(conn)
    end
  end

  describe "if_none_match_exists?" do
    test "returns true if the if-none-match header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-none-match", "asdf")

      assert MyDefaultResource.if_none_match_exists?(conn)
    end

    test "returns false if the if-none-match header is not present" do
      refute MyDefaultResource.if_none_match_exists?(conn(:get, "/"))
    end
  end

  describe "if_none_match_star?" do
    test "returns true if the if-none-match header is *" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-none-match", "*")

      assert MyDefaultResource.if_none_match_star?(conn)
    end

    test "returns false if the if-none-match header is not *" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-none-match", "asdf")

      refute MyDefaultResource.if_none_match_star?(conn)
    end
  end

  defmodule IfMatchModule do
    use Liberator.Resource

    def etag(_), do: "1"
  end

  describe "etag_matches_for_if_match?" do
    test "returns false by default" do
      refute MyDefaultResource.etag_matches_for_if_match?(conn(:get, "/"))
    end

    test "returns the etag if etag matches" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "1")

      assert IfMatchModule.etag_matches_for_if_match?(conn) == %{etag: "1"}
    end
  end

  defmodule IfNoneMatchModule do
    use Liberator.Resource

    def etag(_), do: "1"
  end

  describe "etag_matches_for_if_none?" do
    test "returns false by default" do
      refute MyDefaultResource.etag_matches_for_if_none?(conn(:get, "/"))
    end

    test "returns the etag if etag matches" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-none-match", "1")

      assert IfNoneMatchModule.etag_matches_for_if_none?(conn) == %{etag: "1"}
    end
  end

  describe "post_to_missing?" do
    test "returns true for POST" do
      assert MyDefaultResource.post_to_missing?(conn(:post, "/"))
    end

    test "returns true for GET" do
      refute MyDefaultResource.post_to_missing?(conn(:get, "/"))
    end
  end

  describe "post_to_existing?" do
    test "returns true for POST" do
      assert MyDefaultResource.post_to_existing?(conn(:post, "/"))
    end

    test "returns true for GET" do
      refute MyDefaultResource.post_to_existing?(conn(:get, "/"))
    end
  end

  describe "post_to_gone?" do
    test "returns true for POST" do
      assert MyDefaultResource.post_to_gone?(conn(:post, "/"))
    end

    test "returns true for GET" do
      refute MyDefaultResource.post_to_gone?(conn(:get, "/"))
    end
  end

  describe "put_to_existing?" do
    test "returns true for PUT" do
      assert MyDefaultResource.put_to_existing?(conn(:put, "/"))
    end

    test "returns true for GET" do
      refute MyDefaultResource.put_to_existing?(conn(:get, "/"))
    end
  end
end
