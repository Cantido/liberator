defmodule LiberatorEx.Base do
  import Plug.Conn
  @behaviour LiberatorEx.Resource

  def service_available?(_conn) do
    true
  end

  def known_method?(_conn) do
    true
  end

  def uri_too_long?(_conn) do
    false
  end

  def method_allowed?(_conn) do
    true
  end

  def malformed?(_conn) do
    false
  end

  def authorized?(_conn) do
    true
  end

  def allowed?(_conn) do
    true
  end

  def valid_content_header?(_conn) do
    true
  end

  def known_content_type?(_conn) do
    true
  end

  def valid_entity_length?(_conn) do
    true
  end

  def is_options?(_conn) do
    false
  end

  def accept_exists?(_conn) do
    true
  end

  def media_type_available?(_conn) do
    true
  end

  def accept_language_exists?(_conn) do
    true
  end

  def language_available?(_conn) do
    true
  end

  def accept_charset_exists?(_conn) do
    true
  end

  def charset_available?(_conn) do
    true
  end

  def accept_encoding_exists?(_conn) do
    true
  end

  def encoding_available?(_conn) do
    true
  end

  def processable?(_conn) do
    true
  end

  def exists?(_conn) do
    true
  end

  def if_match_star_exists_for_missing?(_conn) do
    false
  end

  def method_put?(_conn) do
    false
  end

  def existed?(_conn) do
    false
  end

  def post_to_missing?(_conn) do
    false
  end

  def can_post_to_missing?(_conn) do
    false
  end

  def moved_permanently?(_conn) do
    false
  end

  def moved_temporarily?(_conn) do
    false
  end

  def post_to_gone?(_conn) do
    false
  end

  def can_post_to_gone?(_conn) do
    false
  end

  def put_to_different_url?(_conn) do
    false
  end

  def can_put_to_missing?(_conn) do
    false
  end

  def if_match_exists?(_conn) do
    false
  end

  def if_match_star?(_conn) do
    false
  end

  def if_none_match_exists?(_conn) do
    false
  end

  def if_none_match_star?(_conn) do
    false
  end

  def etag_matches_for_if_none?(_conn) do
    false
  end

  def if_none_match?(_conn) do
    false
  end

  def etag_matches_for_if_match?(_conn) do
    false
  end

  def if_modified_since_exists?(_conn) do
    false
  end

  def if_modified_since_valid_date?(_conn) do
    true
  end

  def modified_since?(_conn) do
    false
  end

  def if_unmodified_since_exists?(_conn) do
    false
  end

  def if_unmodified_since_valid_date?(_conn) do
    true
  end

  def unmodified_since?(_conn) do
    true
  end

  def method_delete?(_conn) do
    false
  end

  def method_patch?(_conn) do
    false
  end

  def post_to_existing?(_conn) do
    false
  end

  def put_to_existing?(_conn) do
    false
  end

  def multiple_representations?(_conn) do
    false
  end

  def delete_enacted?(_conn) do
    true
  end

  def respond_with_entity?(_conn) do
    true
  end


  def delete!(_conn) do
    :ok
  end

  def put!(_conn) do
    :ok
  end

  def patch!(_conn) do
    :ok
  end

  def post!(_conn) do
    :ok
  end


  def handle_ok(conn) do
    send_resp(conn, 200, Jason.encode!([]))
  end

  def handle_options(conn) do
    send_resp(conn, 200, Jason.encode!([]))
  end

  def handle_accepted(conn) do
    send_resp(conn, 202, Jason.encode!([]))
  end

  def handle_no_content(conn) do
    send_resp(conn, 204, Jason.encode!([]))
  end

  def handle_multiple_representations(conn) do
    send_resp(conn, 300, Jason.encode!([]))
  end

  def handle_moved_permanently(conn) do
    send_resp(conn, 301, Jason.encode!([]))
  end

  def handle_not_modified(conn) do
    send_resp(conn, 304, Jason.encode!([]))
  end

  def handle_moved_temporarily(conn) do
    send_resp(conn, 307, Jason.encode!([]))
  end

  def handle_malformed(conn) do
    send_resp(conn, 400, Jason.encode!([]))
  end

  def handle_unauthorized(conn) do
    send_resp(conn, 401, Jason.encode!([]))
  end

  def handle_forbidden(conn) do
    send_resp(conn, 403, Jason.encode!([]))
  end

  def handle_not_found(conn) do
    send_resp(conn, 404, Jason.encode!([]))
  end

  def handle_method_not_allowed(conn) do
    send_resp(conn, 405, Jason.encode!([]))
  end

  def handle_not_acceptable(conn) do
    send_resp(conn, 406, Jason.encode!([]))
  end

  def handle_gone(conn) do
    send_resp(conn, 410, Jason.encode!([]))
  end

  def handle_precondition_failed(conn) do
    send_resp(conn, 412, Jason.encode!([]))
  end

  def handle_request_entity_too_large(conn) do
    send_resp(conn, 413, Jason.encode!([]))
  end

  def handle_uri_too_long(conn) do
    send_resp(conn, 414, Jason.encode!([]))
  end

  def handle_unsupported_media_type(conn) do
    send_resp(conn, 415, Jason.encode!([]))
  end

  def handle_unprocessable_entity(conn) do
    send_resp(conn, 422, Jason.encode!([]))
  end

  def handle_not_implemented(conn) do
    send_resp(conn, 501, Jason.encode!([]))
  end

  def handle_unknown_method(conn) do
    send_resp(conn, 501, Jason.encode!([]))
  end

  def handle_service_unavailable(conn) do
    send_resp(conn, 503, Jason.encode!([]))
  end
end
