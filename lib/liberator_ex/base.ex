defmodule LiberatorEx.Base do
  import Plug.Conn
  use Timex
  @behaviour LiberatorEx.Resource

  def allowed_methods(_conn) do
    ["GET", "HEAD", "PUT", "POST", "DELETE", "OPTIONS", "TRACE", "PATCH"]
  end

  def available_media_types(_conn) do
    ["text/plain"]
  end

  def last_modified(_conn) do
    DateTime.utc_now()
  end

  def service_available?(_conn), do: true
  def known_method?(_conn), do: true
  def uri_too_long?(_conn), do: false
  def method_allowed?(conn) do
    conn.method in allowed_methods(conn)
  end
  def malformed?(_conn), do: false
  def authorized?(_conn), do: true
  def allowed?(_conn), do: true
  def valid_content_header?(_conn), do: true
  def known_content_type?(_conn), do: true
  def valid_entity_length?(_conn), do: true

  def is_options?(conn), do: conn.method == "OPTIONS"
  def method_put?(conn), do: conn.method == "PUT"
  def method_post?(conn), do: conn.method == "POST"
  def method_delete?(conn), do: conn.method == "DELETE"
  def method_patch?(conn), do: conn.method == "PATCH"

  def accept_exists?(_conn), do: true
  def media_type_available?(conn) do
    requested_media_type = get_req_header(conn, "accept") |> Enum.at(0)
    requested_media_type in available_media_types(conn)
  end
  def accept_language_exists?(_conn), do: true
  def language_available?(_conn), do: true
  def accept_charset_exists?(_conn), do: true
  def charset_available?(_conn), do: true
  def accept_encoding_exists?(_conn), do: true
  def encoding_available?(_conn), do: true
  def processable?(_conn), do: true

  def exists?(_conn), do: true
  def existed?(_conn), do: false
  def moved_permanently?(_conn), do: false
  def moved_temporarily?(_conn), do: false

  def if_match_star_exists_for_missing?(_conn), do: false
  def post_to_missing?(_conn), do: true
  def post_to_existing?(_conn), do: false
  def post_to_gone?(_conn), do: false
  def can_post_to_missing?(_conn), do: true
  def can_post_to_gone?(_conn), do: false
  def put_to_existing?(_conn), do: false
  def can_put_to_missing?(_conn), do: false
  def put_to_different_url?(_conn), do: false

  def if_match_exists?(_conn), do: false
  def if_match_star?(_conn), do: false
  def if_none_match_exists?(_conn), do: false
  def if_none_match_star?(_conn), do: false
  def etag_matches_for_if_none?(_conn), do: false
  def if_none_match?(_conn), do: false
  def etag_matches_for_if_match?(_conn), do: false
  def if_modified_since_exists?(_conn), do: false
  def if_modified_since_valid_date?(_conn), do: true
  def modified_since?(conn) do
    conn
    |> get_req_header("if-modified-since")
    |> Enum.at(0)
    |> Timex.parse!("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
    |> Timex.before?(last_modified(conn))
  end
  def if_unmodified_since_exists?(_conn), do: false
  def if_unmodified_since_valid_date?(_conn), do: true
  def unmodified_since?(conn) do
    conn
    |> get_req_header("if-unmodified-since")
    |> Enum.at(0)
    |> Timex.parse!("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
    |> Timex.after?(last_modified(conn))
  end
  def post_redirect?(_conn), do: false
  def post_enacted?(_conn), do: false
  def put_enacted?(_conn), do: true
  def delete_enacted?(_conn), do: true
  def patch_enacted?(_conn), do: true
  def respond_with_entity?(_conn), do: true
  def conflict?(_conn), do: false
  def new?(_conn), do: true
  def multiple_representations?(_conn), do: false


  def delete!(_conn) do
    nil
  end

  def put!(_conn) do
    nil
  end

  def patch!(_conn) do
    nil
  end

  def post!(_conn) do
    nil
  end


  def handle_ok(conn) do
    send_resp(conn, 200, "OK")
  end

  def handle_options(conn) do
    send_resp(conn, 200, "Options")
  end

  def handle_created(conn) do
    send_resp(conn, 201, "Created")
  end

  def handle_accepted(conn) do
    send_resp(conn, 202, "Accepted")
  end

  def handle_no_content(conn) do
    send_resp(conn, 204, "No Content")
  end

  def handle_multiple_representations(conn) do
    send_resp(conn, 300, "Multiple Representations")
  end

  def handle_moved_permanently(conn) do
    send_resp(conn, 301, "Moved Permanently")
  end

  def handle_see_other(conn) do
    send_resp(conn, 303, "See Other")
  end

  def handle_not_modified(conn) do
    send_resp(conn, 304, "Not Modified")
  end

  def handle_moved_temporarily(conn) do
    send_resp(conn, 307, "Moved Temporarily")
  end

  def handle_malformed(conn) do
    send_resp(conn, 400, "Malformed")
  end

  def handle_unauthorized(conn) do
    send_resp(conn, 401, "Unauthorized")
  end

  def handle_forbidden(conn) do
    send_resp(conn, 403, "Forbidden")
  end

  def handle_not_found(conn) do
    send_resp(conn, 404, "Not Found")
  end

  def handle_method_not_allowed(conn) do
    send_resp(conn, 405, "Method Not Allowed")
  end

  def handle_not_acceptable(conn) do
    send_resp(conn, 406, "Not Acceptable")
  end

  def handle_conflict(conn) do
    send_resp(conn, 409, "Conflict")
  end

  def handle_gone(conn) do
    send_resp(conn, 410, "Gone")
  end

  def handle_precondition_failed(conn) do
    send_resp(conn, 412, "Precondition Failed")
  end

  def handle_request_entity_too_large(conn) do
    send_resp(conn, 413, "Request Entity Too Large")
  end

  def handle_uri_too_long(conn) do
    send_resp(conn, 414, "URI Too Long")
  end

  def handle_unsupported_media_type(conn) do
    send_resp(conn, 415, "Unsupported Media Type")
  end

  def handle_unprocessable_entity(conn) do
    send_resp(conn, 422, "Unprocessable Entity")
  end

  def handle_not_implemented(conn) do
    send_resp(conn, 501, "Not Implemented")
  end

  def handle_unknown_method(conn) do
    send_resp(conn, 501, "Unknown Method")
  end

  def handle_service_unavailable(conn) do
    send_resp(conn, 503, "Service Unavailable")
  end
end
