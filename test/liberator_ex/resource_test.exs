defmodule LiberatorEx.ResourceTest do
  use ExUnit.Case
  use Plug.Test
  alias LiberatorEx.Resource
  import Mox
  doctest LiberatorEx.Resource

  @opts Resource.init([handler: LiberatorEx.MockResource])

  setup do
    Mox.stub_with(LiberatorEx.MockResource, LiberatorEx.Base)
    :ok
  end

  test "gets index" do
    conn = conn(:get, "/")

    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 503 when service_available? returns false" do
    LiberatorEx.MockResource
    |> expect(:service_available?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 503
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 501 when known_method? returns false" do
    LiberatorEx.MockResource
    |> expect(:known_method?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 501
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 414 when uri_too_long? returns true" do
    LiberatorEx.MockResource
    |> expect(:uri_too_long?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 414
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 405 when method_allowed? returns false" do
    LiberatorEx.MockResource
    |> expect(:method_allowed?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 405
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 400 when malformed? returns true" do
    LiberatorEx.MockResource
    |> expect(:malformed?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 401 when authorized? returns false" do
    LiberatorEx.MockResource
    |> expect(:authorized?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 401
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 403 when allowed? returns false" do
    LiberatorEx.MockResource
    |> expect(:allowed?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 403
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 501 when valid_content_header? returns false" do
    LiberatorEx.MockResource
    |> expect(:valid_content_header?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 501
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 415 when known_content_type? returns false" do
    LiberatorEx.MockResource
    |> expect(:known_content_type?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 415
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 413 when valid_entity_length? returns false" do
    LiberatorEx.MockResource
    |> expect(:valid_entity_length?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 413
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 200-options when is_options? returns true" do
    LiberatorEx.MockResource
    |> expect(:is_options?, fn _ -> true end)

    conn = conn(:options, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 406 when accept_exists? returns true but media_type_available? returns false" do
    LiberatorEx.MockResource
    |> expect(:accept_exists?, fn _ -> true end)
    |> expect(:media_type_available?, fn _ -> false end)

    conn = conn(:options, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 406 when accept_language_exists? returns true but language_available? returns false" do
    LiberatorEx.MockResource
    |> expect(:accept_language_exists?, fn _ -> true end)
    |> expect(:language_available?, fn _ -> false end)

    conn = conn(:options, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 406 when accept_charset_exists? returns true but charset_available? returns false" do
    LiberatorEx.MockResource
    |> expect(:accept_charset_exists?, fn _ -> true end)
    |> expect(:charset_available?, fn _ -> false end)

    conn = conn(:options, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 406 when accept_encoding_exists? returns true but encoding_available? returns false" do
    LiberatorEx.MockResource
    |> expect(:accept_encoding_exists?, fn _ -> true end)
    |> expect(:encoding_available?, fn _ -> false end)

    conn = conn(:options, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 422 when processable? returns false" do
    LiberatorEx.MockResource
    |> expect(:processable?, fn _ -> false end)

    conn = conn(:options, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 422
    assert Jason.decode!(conn.resp_body) == []
  end
end
