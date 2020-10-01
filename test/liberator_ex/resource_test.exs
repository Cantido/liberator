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

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 406 when accept_language_exists? returns true but language_available? returns false" do
    LiberatorEx.MockResource
    |> expect(:accept_language_exists?, fn _ -> true end)
    |> expect(:language_available?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 406 when accept_charset_exists? returns true but charset_available? returns false" do
    LiberatorEx.MockResource
    |> expect(:accept_charset_exists?, fn _ -> true end)
    |> expect(:charset_available?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 406 when accept_encoding_exists? returns true but encoding_available? returns false" do
    LiberatorEx.MockResource
    |> expect(:accept_encoding_exists?, fn _ -> true end)
    |> expect(:encoding_available?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 422 when processable? returns false" do
    LiberatorEx.MockResource
    |> expect(:processable?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 422
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 404 if entity does not exist" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> false end)
    |> expect(:post_to_missing?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 404 if entity does not exist and can't post to missing" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> false end)
    |> expect(:post_to_missing?, fn _ -> true end)
    |> expect(:can_post_to_missing?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 303 if entity does not exist and we can post to missing, and have want a post redirect" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> false end)
    |> expect(:post_to_missing?, fn _ -> true end)
    |> expect(:can_post_to_missing?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 303
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 201 if entity does not exist and we can post to missing, and create a new resource" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> false end)
    |> expect(:post_to_missing?, fn _ -> true end)
    |> expect(:can_post_to_missing?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:new?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 201
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 202 if entity does not exist and we can post to missing, and post is not immediately enacted" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> false end)
    |> expect(:post_to_missing?, fn _ -> true end)
    |> expect(:can_post_to_missing?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 202
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 204 if entity does not exist and we can post to missing, the entity isn't new and we won't respond with entities" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> false end)
    |> expect(:post_to_missing?, fn _ -> true end)
    |> expect(:can_post_to_missing?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> false end)
    |> expect(:new?, fn _ -> false end)
    |> expect(:respond_with_entity?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 204
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 300 if entity does not exist and we can post to missing, the entity isn't new and we have multiple entity representations" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> false end)
    |> expect(:post_to_missing?, fn _ -> true end)
    |> expect(:can_post_to_missing?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> false end)
    |> expect(:new?, fn _ -> false end)
    |> expect(:respond_with_entity?, fn _ -> true end)
    |> expect(:multiple_representations?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 300
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 200 if entity does not exist and we can post to missing, the entity isn't new" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> false end)
    |> expect(:post_to_missing?, fn _ -> true end)
    |> expect(:can_post_to_missing?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> false end)
    |> expect(:new?, fn _ -> false end)
    |> expect(:respond_with_entity?, fn _ -> true end)
    |> expect(:multiple_representations?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 301" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> true end)
    |> expect(:moved_permanently?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 301
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 307" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> true end)
    |> expect(:moved_temporarily?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 307
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 410 if the resource is gone" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> true end)
    |> expect(:post_to_gone?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 410
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 410 when can't post to gone" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> true end)
    |> expect(:post_to_gone?, fn _ -> true end)
    |> expect(:can_post_to_gone?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 410
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 201 when resource is gone but we can post to it" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> false end)
    |> expect(:existed?, fn _ -> true end)
    |> expect(:post_to_gone?, fn _ -> true end)
    |> expect(:can_post_to_gone?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> false end)
    |> expect(:new?, fn _ -> true end)

    conn = conn(:post, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 201
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 301 when put to a different url but entity doesn't exist" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> true end)
    |> expect(:put_to_different_url?, fn _ -> true end)

    conn = conn(:put, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 301
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 501 when put to a different url but entity doesn't exist and can't put to missing" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> true end)
    |> expect(:can_put_to_missing?, fn _ -> false end)

    conn = conn(:put, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 501
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 409 when put to a different url but entity doesn't exist, and we can put to missing, but there's a conflict" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> false end)
    |> expect(:method_put?, fn _ -> true end)
    |> expect(:can_put_to_missing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> true end)

    conn = conn(:put, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 409
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 412 when entity doesn't exist but if_match_star_exists_for_missing is true" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> false end)
    |> expect(:if_match_star_exists_for_missing?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 412
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 412 if If-Match <etag> doesn't match an etag" do
    LiberatorEx.MockResource
    |> expect(:if_match_exists?, fn _ -> true end)
    |> expect(:if_match_star?, fn _ -> false end)
    |> expect(:etag_matches_for_if_match?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 412
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 412 if If-Unmodified-Since <date> and entity has not been modified since" do
    LiberatorEx.MockResource
    |> expect(:if_unmodified_since_exists?, fn _ -> true end)
    |> expect(:if_unmodified_since_valid_date?, fn _ -> true end)
    |> expect(:unmodified_since?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 412
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 412 if If-None-Match <etag> etag does match" do
    LiberatorEx.MockResource
    |> expect(:if_none_match_exists?, fn _ -> true end)
    |> expect(:if_none_match_star?, fn _ -> false end)
    |> expect(:etag_matches_for_if_none?, fn _ -> true end)
    |> expect(:if_none_match?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 412
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 412 if If-None-Match * etag does match" do
    LiberatorEx.MockResource
    |> expect(:if_none_match_exists?, fn _ -> true end)
    |> expect(:if_none_match_star?, fn _ -> true end)
    |> expect(:if_none_match?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 412
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 304 if If-None-Match <etag> etag does't match" do
    LiberatorEx.MockResource
    |> expect(:if_none_match_exists?, fn _ -> true end)
    |> expect(:if_none_match_star?, fn _ -> false end)
    |> expect(:etag_matches_for_if_none?, fn _ -> true end)
    |> expect(:if_none_match?, fn _ -> true end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 304
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 304 if If-Modified-Since <date> and resource has not been modified" do
    LiberatorEx.MockResource
    |> expect(:if_modified_since_exists?, fn _ -> true end)
    |> expect(:if_modified_since_valid_date?, fn _ -> true end)
    |> expect(:modified_since?, fn _ -> false end)

    conn = conn(:get, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 304
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 200 if method is delete" do
    LiberatorEx.MockResource
    |> expect(:method_delete?, fn _ -> true end)
    |> expect(:delete!, fn _ -> :ok end)

    conn = conn(:delete, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 202 if method is delete but delete is not immediately enacted" do
    LiberatorEx.MockResource
    |> expect(:method_delete?, fn _ -> true end)
    |> expect(:delete!, fn _ -> nil end)
    |> expect(:delete_enacted?, fn _ -> false end)

    conn = conn(:delete, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 202
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 204 if method is delete and no content is returned" do
    LiberatorEx.MockResource
    |> expect(:method_delete?, fn _ -> true end)
    |> expect(:delete!, fn _ -> nil end)
    |> expect(:respond_with_entity?, fn _ -> false end)

    conn = conn(:delete, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 204
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 200 if method is patch" do
    LiberatorEx.MockResource
    |> expect(:method_delete?, fn _ -> true end)
    |> expect(:patch!, fn _ -> nil end)

    conn = conn(:patch, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 202 if method is patch and patch is not immediately enacted" do
    LiberatorEx.MockResource
    |> expect(:method_patch?, fn _ -> true end)
    |> expect(:patch!, fn _ -> nil end)
    |> expect(:patch_enacted?, fn _ -> false end)

    conn = conn(:patch, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 202
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 204 if method is patch and no content is returned" do
    LiberatorEx.MockResource
    |> expect(:method_patch?, fn _ -> true end)
    |> expect(:patch!, fn _ -> nil end)
    |> expect(:respond_with_entity?, fn _ -> false end)

    conn = conn(:patch, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 204
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 409 if post-to-existing has a conflict" do
    LiberatorEx.MockResource
    |> expect(:post_to_existing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> true end)

    conn = conn(:post, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 409
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 409 if put-to-existing has a conflict" do
    LiberatorEx.MockResource
    |> expect(:put_to_existing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> true end)

    conn = conn(:put, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 409
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 303 if post with post-redirect enabled" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> true end)
    |> expect(:if_match_exists?, fn _ -> false end)
    |> expect(:if_unmodified_since_exists?, fn _ -> false end)
    |> expect(:if_none_match_exists?, fn _ -> false end)
    |> expect(:if_modified_since_exists?, fn _ -> false end)
    |> expect(:method_delete?, fn _ -> false end)
    |> expect(:method_patch?, fn _ -> false end)
    |> expect(:post_to_existing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> false end)
    |> expect(:method_post?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> true end)

    conn = conn(:post, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 303
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 201 if post when resource is created" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> true end)
    |> expect(:if_match_exists?, fn _ -> false end)
    |> expect(:if_unmodified_since_exists?, fn _ -> false end)
    |> expect(:if_none_match_exists?, fn _ -> false end)
    |> expect(:if_modified_since_exists?, fn _ -> false end)
    |> expect(:method_delete?, fn _ -> false end)
    |> expect(:method_patch?, fn _ -> false end)
    |> expect(:post_to_existing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> false end)
    |> expect(:method_post?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> false end)
    |> expect(:new?, fn _ -> true end)

    conn = conn(:post, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 201
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 204 if post when resource is not new and we want no entity response" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> true end)
    |> expect(:if_match_exists?, fn _ -> false end)
    |> expect(:if_unmodified_since_exists?, fn _ -> false end)
    |> expect(:if_none_match_exists?, fn _ -> false end)
    |> expect(:if_modified_since_exists?, fn _ -> false end)
    |> expect(:method_delete?, fn _ -> false end)
    |> expect(:method_patch?, fn _ -> false end)
    |> expect(:post_to_existing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> false end)
    |> expect(:method_post?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> false end)
    |> expect(:new?, fn _ -> false end)
    |> expect(:respond_with_entity?, fn _ -> false end)

    conn = conn(:post, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 204
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 200 if post when resource is not new and we want an entity response with one representation" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> true end)
    |> expect(:if_match_exists?, fn _ -> false end)
    |> expect(:if_unmodified_since_exists?, fn _ -> false end)
    |> expect(:if_none_match_exists?, fn _ -> false end)
    |> expect(:if_modified_since_exists?, fn _ -> false end)
    |> expect(:method_delete?, fn _ -> false end)
    |> expect(:method_patch?, fn _ -> false end)
    |> expect(:post_to_existing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> false end)
    |> expect(:method_post?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> false end)
    |> expect(:new?, fn _ -> false end)
    |> expect(:respond_with_entity?, fn _ -> true end)
    |> expect(:multiple_representations?, fn _ -> false end)

    conn = conn(:post, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 300 if post when resource is not new and we want an entity response with multiple representations" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> true end)
    |> expect(:if_match_exists?, fn _ -> false end)
    |> expect(:if_unmodified_since_exists?, fn _ -> false end)
    |> expect(:if_none_match_exists?, fn _ -> false end)
    |> expect(:if_modified_since_exists?, fn _ -> false end)
    |> expect(:method_delete?, fn _ -> false end)
    |> expect(:method_patch?, fn _ -> false end)
    |> expect(:post_to_existing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> false end)
    |> expect(:method_post?, fn _ -> true end)
    |> expect(:post_enacted?, fn _ -> true end)
    |> expect(:post_redirect?, fn _ -> false end)
    |> expect(:new?, fn _ -> false end)
    |> expect(:respond_with_entity?, fn _ -> true end)
    |> expect(:multiple_representations?, fn _ -> true end)

    conn = conn(:post, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 300
    assert Jason.decode!(conn.resp_body) == []
  end

  test "returns 201 if put when resource is new" do
    LiberatorEx.MockResource
    |> expect(:exists?, fn _ -> true end)
    |> expect(:if_match_exists?, fn _ -> false end)
    |> expect(:if_unmodified_since_exists?, fn _ -> false end)
    |> expect(:if_none_match_exists?, fn _ -> false end)
    |> expect(:if_modified_since_exists?, fn _ -> false end)
    |> expect(:method_delete?, fn _ -> false end)
    |> expect(:method_patch?, fn _ -> false end)
    |> expect(:post_to_existing?, fn _ -> true end)
    |> expect(:conflict?, fn _ -> false end)
    |> expect(:method_post?, fn _ -> false end)
    |> expect(:put_enacted?, fn _ -> true end)
    |> expect(:new?, fn _ -> true end)

    conn = conn(:post, "/")
    conn = Resource.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 201
    assert Jason.decode!(conn.resp_body) == []
  end
end
