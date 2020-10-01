defmodule LiberatorEx.ResourceTest do
  use ExUnit.Case
  use Plug.Test
  alias LiberatorEx.Resource
  doctest LiberatorEx.Resource

  defmodule MyResource do
    use LiberatorEx.Resource
  end

  describe "method_allowed?/1" do
    test "allows GET" do
      assert MyResource.method_allowed?(conn(:get, "/"))
    end

    test "allows HEAD" do
      assert MyResource.method_allowed?(conn(:get, "/"))
    end

    test "allows PUT" do
      assert MyResource.method_allowed?(conn(:get, "/"))
    end

    test "allows POST" do
      assert MyResource.method_allowed?(conn(:get, "/"))
    end

    test "allows DELETE" do
      assert MyResource.method_allowed?(conn(:get, "/"))
    end

    test "allows OPTIONS" do
      assert MyResource.method_allowed?(conn(:get, "/"))
    end

    test "allows TRACE" do
      assert MyResource.method_allowed?(conn(:get, "/"))
    end

    test "allows PATCH" do
      assert MyResource.method_allowed?(conn(:get, "/"))
    end

    test "disallows asdf" do
      assert not MyResource.method_allowed?(conn(:asdf, "/"))
    end
  end

  describe "is_options?" do
    test "returns true for options type" do
      assert MyResource.is_options?(conn(:options, "/"))
    end

    test "returns false for non-options type" do
      assert not MyResource.is_options?(conn(:get, "/"))
    end
  end

  describe "method_put?" do
    test "returns true for put type" do
      assert MyResource.method_put?(conn(:put, "/"))
    end

    test "returns false for non-put type" do
      assert not MyResource.method_put?(conn(:get, "/"))
    end
  end

  describe "method_post?" do
    test "returns true for post type" do
      assert MyResource.method_post?(conn(:post, "/"))
    end

    test "returns false for non-post type" do
      assert not MyResource.method_post?(conn(:get, "/"))
    end
  end

  describe "method_delete?" do
    test "returns true for delete type" do
      assert MyResource.method_delete?(conn(:delete, "/"))
    end

    test "returns false for non-delete type" do
      assert not MyResource.method_delete?(conn(:get, "/"))
    end
  end

  describe "method_patch?" do
    test "returns true for patch type" do
      assert MyResource.method_patch?(conn(:patch, "/"))
    end

    test "returns false for non-patch type" do
      assert not MyResource.method_patch?(conn(:get, "/"))
    end
  end

  describe "accept_exists?/1" do
    test "returns true if the accept header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "application/json")

      assert MyResource.accept_exists?(conn)
    end
    test "returns true if the accept header is */*" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", "*/*")

      assert MyResource.accept_exists?(conn)
    end
    test "returns false if the accept header is not present" do
      assert not MyResource.accept_exists?(conn(:get, "/"))
    end
  end

  describe "accept_language_exists?/1" do
    test "returns true if the accept-language header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-language", "en")

      assert MyResource.accept_language_exists?(conn)
    end
    test "returns false if the accept-language header is not present" do
      assert not MyResource.accept_language_exists?(conn(:get, "/"))
    end
  end

  describe "accept_charset_exists?/1" do
    test "returns true if the accept-charset header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-charset", "en")

      assert MyResource.accept_charset_exists?(conn)
    end
    test "returns false if the accept-charset header is not present" do
      assert not MyResource.accept_charset_exists?(conn(:get, "/"))
    end
  end

  describe "accept_encoding_exists?/1" do
    test "returns true if the accept-encoding header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept-encoding", "en")

      assert MyResource.accept_encoding_exists?(conn)
    end
    test "returns false if the accept-encoding header is not present" do
      assert not MyResource.accept_encoding_exists?(conn(:get, "/"))
    end
  end

  describe "media_type_available?/1" do
    test "allows text/plain" do
      assert MyResource.media_type_available?(conn(:get, "/") |> put_req_header("accept", "text/plain"))
    end
    test "disallows text/nonexistent-media-type" do
      assert not MyResource.media_type_available?(conn(:get, "/") |> put_req_header("accept", "text/nonexistent-media-type"))
    end
  end

  describe "if_modified_since_exists?" do
    test "returns true if the if-modified-since header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", "*")

      assert MyResource.if_modified_since_exists?(conn)
    end
    test "returns false if the if-modified-since header is not present" do
      assert not MyResource.if_modified_since_exists?(conn(:get, "/"))
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

      assert MyResource.modified_since?(conn)
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

      assert not MyResource.modified_since?(conn)
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

      assert MyResource.if_modified_since_valid_date?(conn)
    end
    test "returns false if if_modified_since header contains an invalid date" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-modified-since", "asdf")

      assert not MyResource.if_modified_since_valid_date?(conn)
    end
  end

  describe "if_unmodified_since_exists?" do
    test "returns true if the if-unmodified-since header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", "*")

      assert MyResource.if_unmodified_since_exists?(conn)
    end
    test "returns false if the if-unmodified-since header is not present" do
      assert not MyResource.if_unmodified_since_exists?(conn(:get, "/"))
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

      assert MyResource.if_unmodified_since_valid_date?(conn)
    end
    test "returns false if if_unmodified_since header contains an invalid date" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-unmodified-since", "asdf")

      assert not MyResource.if_unmodified_since_valid_date?(conn)
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

      assert not MyResource.unmodified_since?(conn)
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

      assert MyResource.unmodified_since?(conn)
    end
  end

  describe "if_match_exists?" do
    test "returns true if the if-match header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "*")

      assert MyResource.if_match_exists?(conn)
    end
    test "returns false if the if-match header is not present" do
      assert not MyResource.if_match_exists?(conn(:get, "/"))
    end
  end

  describe "if_match_star?" do
    test "returns true if the if-match * header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "*")

      assert MyResource.if_match_star?(conn)
    end
    test "returns false if the if-match * header is not present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-match", "abcdefg")

      assert not MyResource.if_match_star?(conn)
    end
  end

  describe "if_none_match_exists?" do
    test "returns true if the if-none-match header is present" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-none-match", "asdf")

      assert MyResource.if_none_match_exists?(conn)
    end
    test "returns false if the if-none-match header is not present" do
      assert not MyResource.if_none_match_exists?(conn(:get, "/"))
    end
  end

  describe "if_none_match_star?" do
    test "returns true if the if-none-match header is *" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-none-match", "*")

      assert MyResource.if_none_match_star?(conn)
    end
    test "returns false if the if-none-match header is not *" do
      conn =
        conn(:get, "/")
        |> put_req_header("if-none-match", "asdf")

      assert not MyResource.if_none_match_star?(conn)
    end
  end

  describe "etag_matches_for_if_match?" do
    test "returns false by default" do
      assert not MyResource.etag_matches_for_if_match?(conn(:get, "/"))
    end
  end

  describe "etag_matches_for_if_none?" do
    test "returns false by default" do
      assert not MyResource.etag_matches_for_if_none?(conn(:get, "/"))
    end
  end

  test "gets index" do
    conn = conn(:get, "/")

    conn = MyResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "returns 503 when service_available? returns false" do
    defmodule UnavailableResource do
      use LiberatorEx.Resource
      @impl true
      def service_available?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = UnavailableResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 503
    assert conn.resp_body == "Service Unavailable"
  end

  test "returns 501 when known_method? returns false" do
    defmodule UnknownMethodResource do
      use LiberatorEx.Resource
      @impl true
      def known_method?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = UnknownMethodResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 501
    assert  conn.resp_body == "Unknown Method"
  end

  test "returns 414 when uri_too_long? returns true" do
    defmodule UriTooLongResource do
      use LiberatorEx.Resource
      @impl true
      def uri_too_long?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = UriTooLongResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 414
    assert conn.resp_body == "URI Too Long"
  end

  test "returns 405 when method_allowed? returns false" do
    defmodule MethodNotAllowedResource do
      use LiberatorEx.Resource
      @impl true
      def method_allowed?(_conn), do: false
    end

    conn = conn(:get, "/")
    conn = MethodNotAllowedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 405
    assert conn.resp_body == "Method Not Allowed"
  end

  test "returns 400 when malformed? returns true" do
    defmodule MalformedResource do
      use LiberatorEx.Resource
      @impl true
      def malformed?(_conn), do: true
    end

    conn = conn(:get, "/")
    conn = MalformedResource.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "Malformed"
  end

  # test "returns 401 when authorized? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:authorized?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 401
  #   assert conn.resp_body == "Unauthorized"
  # end
  #
  # test "returns 403 when allowed? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:allowed?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 403
  #   assert conn.resp_body == "Forbidden"
  # end
  #
  # test "returns 501 when valid_content_header? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:valid_content_header?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 501
  #   assert conn.resp_body == "Not Implemented"
  # end
  #
  # test "returns 415 when known_content_type? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:known_content_type?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 415
  #   assert conn.resp_body == "Unsupported Media Type"
  # end
  #
  # test "returns 413 when valid_entity_length? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:valid_entity_length?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 413
  #   assert conn.resp_body == "Request Entity Too Large"
  # end
  #
  # test "returns 200-options for an options request" do
  #   LiberatorEx.MockResource
  #   |> expect(:is_options?, fn _ -> true end)
  #
  #   conn = conn(:options, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 200
  #   assert conn.resp_body == "Options"
  # end
  #
  # test "returns 406 when accept_exists? returns true but media_type_available? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:accept_exists?, fn _ -> true end)
  #   |> expect(:media_type_available?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 406
  #   assert conn.resp_body == "Not Acceptable"
  # end
  #
  # test "returns 406 when accept_language_exists? returns true but language_available? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:accept_language_exists?, fn _ -> true end)
  #   |> expect(:language_available?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 406
  #   assert conn.resp_body == "Not Acceptable"
  # end
  #
  # test "returns 406 when accept_charset_exists? returns true but charset_available? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:accept_charset_exists?, fn _ -> true end)
  #   |> expect(:charset_available?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 406
  #   assert conn.resp_body == "Not Acceptable"
  # end
  #
  # test "returns 406 when accept_encoding_exists? returns true but encoding_available? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:accept_encoding_exists?, fn _ -> true end)
  #   |> expect(:encoding_available?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 406
  #   assert conn.resp_body == "Not Acceptable"
  # end
  #
  # test "returns 422 when processable? returns false" do
  #   LiberatorEx.MockResource
  #   |> expect(:processable?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 422
  #   assert conn.resp_body == "Unprocessable Entity"
  # end
  #
  # test "returns 404 if entity does not exist" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> false end)
  #   |> expect(:post_to_missing?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 404
  #   assert conn.resp_body == "Not Found"
  # end
  #
  # test "returns 404 if entity does not exist and can't post to missing" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> false end)
  #   |> expect(:post_to_missing?, fn _ -> true end)
  #   |> expect(:can_post_to_missing?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 404
  #   assert conn.resp_body == "Not Found"
  # end
  #
  # test "returns 303 if entity does not exist and we can post to missing, and have want a post redirect" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> false end)
  #   |> expect(:post_to_missing?, fn _ -> true end)
  #   |> expect(:can_post_to_missing?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> true end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 303
  #   assert conn.resp_body == "See Other"
  # end
  #
  # test "returns 201 if entity does not exist and we can post to missing, and create a new resource" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> false end)
  #   |> expect(:post_to_missing?, fn _ -> true end)
  #   |> expect(:can_post_to_missing?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:new?, fn _ -> true end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 201
  #   assert conn.resp_body == "Created"
  # end
  #
  # test "returns 202 if entity does not exist and we can post to missing, and post is not immediately enacted" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> false end)
  #   |> expect(:post_to_missing?, fn _ -> true end)
  #   |> expect(:can_post_to_missing?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 202
  #   assert conn.resp_body == "Accepted"
  # end
  #
  # test "returns 204 if entity does not exist and we can post to missing, the entity isn't new and we won't respond with entities" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> false end)
  #   |> expect(:post_to_missing?, fn _ -> true end)
  #   |> expect(:can_post_to_missing?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> false end)
  #   |> expect(:new?, fn _ -> false end)
  #   |> expect(:respond_with_entity?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 204
  #   assert conn.resp_body == "No Content"
  # end
  #
  # test "returns 300 if entity does not exist and we can post to missing, the entity isn't new and we have multiple entity representations" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> false end)
  #   |> expect(:post_to_missing?, fn _ -> true end)
  #   |> expect(:can_post_to_missing?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> false end)
  #   |> expect(:new?, fn _ -> false end)
  #   |> expect(:respond_with_entity?, fn _ -> true end)
  #   |> expect(:multiple_representations?, fn _ -> true end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 300
  #   assert conn.resp_body == "Multiple Representations"
  # end
  #
  # test "returns 200 if entity does not exist and we can post to missing, the entity isn't new" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> false end)
  #   |> expect(:post_to_missing?, fn _ -> true end)
  #   |> expect(:can_post_to_missing?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> false end)
  #   |> expect(:new?, fn _ -> false end)
  #   |> expect(:respond_with_entity?, fn _ -> true end)
  #   |> expect(:multiple_representations?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 200
  #   assert conn.resp_body == "OK"
  # end
  #
  # test "returns 301" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> true end)
  #   |> expect(:moved_permanently?, fn _ -> true end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 301
  #   assert conn.resp_body == "Moved Permanently"
  # end
  #
  # test "returns 307" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> true end)
  #   |> expect(:moved_temporarily?, fn _ -> true end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 307
  #   assert conn.resp_body == "Moved Temporarily"
  # end
  #
  # test "returns 410 if the resource is gone" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> true end)
  #   |> expect(:post_to_gone?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 410
  #   assert conn.resp_body == "Gone"
  # end
  #
  # test "returns 410 when can't post to gone" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> true end)
  #   |> expect(:post_to_gone?, fn _ -> true end)
  #   |> expect(:can_post_to_gone?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 410
  #   assert conn.resp_body == "Gone"
  # end
  #
  # test "returns 201 when resource is gone but we can post to it" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> false end)
  #   |> expect(:existed?, fn _ -> true end)
  #   |> expect(:post_to_gone?, fn _ -> true end)
  #   |> expect(:can_post_to_gone?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> false end)
  #   |> expect(:new?, fn _ -> true end)
  #
  #   conn = conn(:post, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 201
  #   assert conn.resp_body == "Created"
  # end
  #
  # test "returns 301 when put to a different url but entity doesn't exist" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> true end)
  #   |> expect(:put_to_different_url?, fn _ -> true end)
  #
  #   conn = conn(:put, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 301
  #   assert conn.resp_body == "Moved Permanently"
  # end
  #
  # test "returns 501 when put to a different url but entity doesn't exist and can't put to missing" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> true end)
  #   |> expect(:can_put_to_missing?, fn _ -> false end)
  #
  #   conn = conn(:put, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 501
  #   assert conn.resp_body == "Not Implemented"
  # end
  #
  # test "returns 409 when put to a different url but entity doesn't exist, and we can put to missing, but there's a conflict" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
  #   |> expect(:method_put?, fn _ -> true end)
  #   |> expect(:can_put_to_missing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> true end)
  #
  #   conn = conn(:put, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 409
  #   assert conn.resp_body == "Conflict"
  # end
  #
  # test "returns 412 when entity doesn't exist but if_match_star_exists_for_missing is true" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> false end)
  #   |> expect(:if_match_star_exists_for_missing?, fn _ -> true end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 412
  #   assert conn.resp_body == "Precondition Failed"
  # end
  #
  # test "returns 412 if If-Match <etag> doesn't match an etag" do
  #   LiberatorEx.MockResource
  #   |> expect(:if_match_exists?, fn _ -> true end)
  #   |> expect(:if_match_star?, fn _ -> false end)
  #   |> expect(:etag_matches_for_if_match?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 412
  #   assert conn.resp_body == "Precondition Failed"
  # end
  #
  # test "returns 412 if If-Unmodified-Since <date> and entity has not been modified since" do
  #   LiberatorEx.MockResource
  #   |> expect(:if_unmodified_since_exists?, fn _ -> true end)
  #   |> expect(:if_unmodified_since_valid_date?, fn _ -> true end)
  #   |> expect(:unmodified_since?, fn _ -> true end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 412
  #   assert conn.resp_body == "Precondition Failed"
  # end
  #
  # test "returns 412 if If-None-Match <etag> etag does match" do
  #   LiberatorEx.MockResource
  #   |> expect(:if_none_match_exists?, fn _ -> true end)
  #   |> expect(:if_none_match_star?, fn _ -> false end)
  #   |> expect(:etag_matches_for_if_none?, fn _ -> true end)
  #   |> expect(:if_none_match?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 412
  #   assert conn.resp_body == "Precondition Failed"
  # end
  #
  # test "returns 412 if If-None-Match * etag does match" do
  #   LiberatorEx.MockResource
  #   |> expect(:if_none_match_exists?, fn _ -> true end)
  #   |> expect(:if_none_match_star?, fn _ -> true end)
  #   |> expect(:if_none_match?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 412
  #   assert conn.resp_body == "Precondition Failed"
  # end
  #
  # test "returns 304 if If-None-Match <etag> etag does't match" do
  #   LiberatorEx.MockResource
  #   |> expect(:if_none_match_exists?, fn _ -> true end)
  #   |> expect(:if_none_match_star?, fn _ -> false end)
  #   |> expect(:etag_matches_for_if_none?, fn _ -> true end)
  #   |> expect(:if_none_match?, fn _ -> true end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 304
  #   assert conn.resp_body == "Not Modified"
  # end
  #
  # test "returns 304 if If-Modified-Since <date> and resource has not been modified" do
  #   LiberatorEx.MockResource
  #   |> expect(:if_modified_since_exists?, fn _ -> true end)
  #   |> expect(:if_modified_since_valid_date?, fn _ -> true end)
  #   |> expect(:modified_since?, fn _ -> false end)
  #
  #   conn = conn(:get, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 304
  #   assert conn.resp_body == "Not Modified"
  # end
  #
  # test "returns 200 if method is delete" do
  #   LiberatorEx.MockResource
  #   |> expect(:method_delete?, fn _ -> true end)
  #   |> expect(:delete!, fn _ -> :ok end)
  #
  #   conn = conn(:delete, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 200
  #   assert conn.resp_body == "OK"
  # end
  #
  # test "returns 202 if method is delete but delete is not immediately enacted" do
  #   LiberatorEx.MockResource
  #   |> expect(:method_delete?, fn _ -> true end)
  #   |> expect(:delete!, fn _ -> nil end)
  #   |> expect(:delete_enacted?, fn _ -> false end)
  #
  #   conn = conn(:delete, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 202
  #   assert conn.resp_body == "Accepted"
  # end
  #
  # test "returns 204 if method is delete and no content is returned" do
  #   LiberatorEx.MockResource
  #   |> expect(:method_delete?, fn _ -> true end)
  #   |> expect(:delete!, fn _ -> nil end)
  #   |> expect(:respond_with_entity?, fn _ -> false end)
  #
  #   conn = conn(:delete, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 204
  #   assert conn.resp_body == "No Content"
  # end
  #
  # test "returns 200 if method is patch" do
  #   LiberatorEx.MockResource
  #   |> expect(:method_delete?, fn _ -> true end)
  #   |> expect(:patch!, fn _ -> nil end)
  #
  #   conn = conn(:patch, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 200
  #   assert conn.resp_body == "OK"
  # end
  #
  # test "returns 202 if method is patch and patch is not immediately enacted" do
  #   LiberatorEx.MockResource
  #   |> expect(:method_patch?, fn _ -> true end)
  #   |> expect(:patch!, fn _ -> nil end)
  #   |> expect(:patch_enacted?, fn _ -> false end)
  #
  #   conn = conn(:patch, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 202
  #   assert conn.resp_body == "Accepted"
  # end
  #
  # test "returns 204 if method is patch and no content is returned" do
  #   LiberatorEx.MockResource
  #   |> expect(:method_patch?, fn _ -> true end)
  #   |> expect(:patch!, fn _ -> nil end)
  #   |> expect(:respond_with_entity?, fn _ -> false end)
  #
  #   conn = conn(:patch, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 204
  #   assert conn.resp_body == "No Content"
  # end
  #
  # test "returns 409 if post-to-existing has a conflict" do
  #   LiberatorEx.MockResource
  #   |> expect(:post_to_existing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> true end)
  #
  #   conn = conn(:post, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 409
  #   assert conn.resp_body == "Conflict"
  # end
  #
  # test "returns 409 if put-to-existing has a conflict" do
  #   LiberatorEx.MockResource
  #   |> expect(:put_to_existing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> true end)
  #
  #   conn = conn(:put, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 409
  #   assert conn.resp_body == "Conflict"
  # end
  #
  # test "returns 303 if post with post-redirect enabled" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> true end)
  #   |> expect(:if_match_exists?, fn _ -> false end)
  #   |> expect(:if_unmodified_since_exists?, fn _ -> false end)
  #   |> expect(:if_none_match_exists?, fn _ -> false end)
  #   |> expect(:if_modified_since_exists?, fn _ -> false end)
  #   |> expect(:method_delete?, fn _ -> false end)
  #   |> expect(:method_patch?, fn _ -> false end)
  #   |> expect(:post_to_existing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> false end)
  #   |> expect(:method_post?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> true end)
  #
  #   conn = conn(:post, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 303
  #   assert conn.resp_body == "See Other"
  # end
  #
  # test "returns 201 if post when resource is created" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> true end)
  #   |> expect(:if_match_exists?, fn _ -> false end)
  #   |> expect(:if_unmodified_since_exists?, fn _ -> false end)
  #   |> expect(:if_none_match_exists?, fn _ -> false end)
  #   |> expect(:if_modified_since_exists?, fn _ -> false end)
  #   |> expect(:method_delete?, fn _ -> false end)
  #   |> expect(:method_patch?, fn _ -> false end)
  #   |> expect(:post_to_existing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> false end)
  #   |> expect(:method_post?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> false end)
  #   |> expect(:new?, fn _ -> true end)
  #
  #   conn = conn(:post, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 201
  #   assert conn.resp_body == "Created"
  # end
  #
  # test "returns 204 if post when resource is not new and we want no entity response" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> true end)
  #   |> expect(:if_match_exists?, fn _ -> false end)
  #   |> expect(:if_unmodified_since_exists?, fn _ -> false end)
  #   |> expect(:if_none_match_exists?, fn _ -> false end)
  #   |> expect(:if_modified_since_exists?, fn _ -> false end)
  #   |> expect(:method_delete?, fn _ -> false end)
  #   |> expect(:method_patch?, fn _ -> false end)
  #   |> expect(:post_to_existing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> false end)
  #   |> expect(:method_post?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> false end)
  #   |> expect(:new?, fn _ -> false end)
  #   |> expect(:respond_with_entity?, fn _ -> false end)
  #
  #   conn = conn(:post, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 204
  #   assert conn.resp_body == "No Content"
  # end
  #
  # test "returns 200 if post when resource is not new and we want an entity response with one representation" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> true end)
  #   |> expect(:if_match_exists?, fn _ -> false end)
  #   |> expect(:if_unmodified_since_exists?, fn _ -> false end)
  #   |> expect(:if_none_match_exists?, fn _ -> false end)
  #   |> expect(:if_modified_since_exists?, fn _ -> false end)
  #   |> expect(:method_delete?, fn _ -> false end)
  #   |> expect(:method_patch?, fn _ -> false end)
  #   |> expect(:post_to_existing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> false end)
  #   |> expect(:method_post?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> false end)
  #   |> expect(:new?, fn _ -> false end)
  #   |> expect(:respond_with_entity?, fn _ -> true end)
  #   |> expect(:multiple_representations?, fn _ -> false end)
  #
  #   conn = conn(:post, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 200
  #   assert conn.resp_body == "OK"
  # end
  #
  # test "returns 300 if post when resource is not new and we want an entity response with multiple representations" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> true end)
  #   |> expect(:if_match_exists?, fn _ -> false end)
  #   |> expect(:if_unmodified_since_exists?, fn _ -> false end)
  #   |> expect(:if_none_match_exists?, fn _ -> false end)
  #   |> expect(:if_modified_since_exists?, fn _ -> false end)
  #   |> expect(:method_delete?, fn _ -> false end)
  #   |> expect(:method_patch?, fn _ -> false end)
  #   |> expect(:post_to_existing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> false end)
  #   |> expect(:method_post?, fn _ -> true end)
  #   |> expect(:post_enacted?, fn _ -> true end)
  #   |> expect(:post_redirect?, fn _ -> false end)
  #   |> expect(:new?, fn _ -> false end)
  #   |> expect(:respond_with_entity?, fn _ -> true end)
  #   |> expect(:multiple_representations?, fn _ -> true end)
  #
  #   conn = conn(:post, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 300
  #   assert conn.resp_body == "Multiple Representations"
  # end
  #
  # test "returns 201 if put when resource is new" do
  #   LiberatorEx.MockResource
  #   |> expect(:exists?, fn _ -> true end)
  #   |> expect(:if_match_exists?, fn _ -> false end)
  #   |> expect(:if_unmodified_since_exists?, fn _ -> false end)
  #   |> expect(:if_none_match_exists?, fn _ -> false end)
  #   |> expect(:if_modified_since_exists?, fn _ -> false end)
  #   |> expect(:method_delete?, fn _ -> false end)
  #   |> expect(:method_patch?, fn _ -> false end)
  #   |> expect(:post_to_existing?, fn _ -> true end)
  #   |> expect(:conflict?, fn _ -> false end)
  #   |> expect(:method_post?, fn _ -> false end)
  #   |> expect(:put_enacted?, fn _ -> true end)
  #   |> expect(:new?, fn _ -> true end)
  #
  #   conn = conn(:post, "/")
  #   conn = Resource.call(conn, [])
  #
  #   assert conn.state == :sent
  #   assert conn.status == 201
  #   assert conn.resp_body == "Created"
  # end
end
