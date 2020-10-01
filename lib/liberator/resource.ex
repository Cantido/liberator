defmodule Liberator.Resource do
  use Plug.Builder
  @moduledoc """
  A controller module that understands and respects the HTTP spec.

  This module implements a `Plug` handler that allows an endpoint to comply to the HTTP specification,
  and to do so by just answering a few questions.

  Define a simple resource like this:

      defmodule MyFirstResource do
        use Liberator.Resource

        def available_media_types(_), do: ["text/plain"]
        def handle_ok(conn), do: send_resp(conn, 200, "Hello world!")
      end

  There are lots of decisions to be made during content negotiation,
  and Liberator lets gives you access to every single one,
  but it's also built with sensible defaults that let you quickly build up a controller.
  """

  @doc """
  Returns a list of HTTP methods that this module serves.

  The methods returned by this function should be upper-case strings, like `"GET"`, `"POST"`, etc.
  """
  @callback allowed_methods(Plug.Conn.t) :: list()

  @doc """
  Returns a list of content types that this module serves.

  The types returned by this function should be valid MIME types, like `text/plain`, `application/json`, etc.
  """
  @callback available_media_types(Plug.Conn.t) :: list()

  @doc """
  Returns a list of available languages.
  """
  @callback available_languages(Plug.Conn.t) :: list()

  @callback available_encodings(Plug.Conn.t) :: list()
  @callback available_charsets(Plug.Conn.t) :: list()
  @doc """
  Returns the last modified date of your resource.

  This value will be used to respond to caching headers like `If-Modified-Since`.
  """
  @callback last_modified(Plug.Conn.t) :: DateTime.t

  @doc """
  Returns the etag for the current entity.

  This value will be used to respond to caching headers like `If-None-Match`.
  """
  @callback etag(Plug.Conn.t) :: String.t

  @doc """
  Check if your service is available.

  This is the first function called in the entire pipeline,
  and lets you check to make sure everything works before going deeper.
  Defaults to `true`.
  """
  @callback service_available?(Plug.Conn.t) :: true | false

  @doc """

  """
  @callback known_method?(Plug.Conn.t) :: true | false
  @callback uri_too_long?(Plug.Conn.t) :: true | false
  @callback method_allowed?(Plug.Conn.t) :: true | false
  @callback malformed?(Plug.Conn.t) :: true | false
  @callback authorized?(Plug.Conn.t) :: true | false
  @callback allowed?(Plug.Conn.t) :: true | false
  @callback valid_content_header?(Plug.Conn.t) :: true | false
  @callback known_content_type?(Plug.Conn.t) :: true | false
  @callback valid_entity_length?(Plug.Conn.t) :: true | false
  @callback is_options?(Plug.Conn.t) :: true | false
  @callback accept_exists?(Plug.Conn.t) :: true | false
  @callback media_type_available?(Plug.Conn.t) :: true | false
  @callback accept_language_exists?(Plug.Conn.t) :: true | false
  @callback language_available?(Plug.Conn.t) :: true | false
  @callback accept_charset_exists?(Plug.Conn.t) :: true | false
  @callback charset_available?(Plug.Conn.t) :: true | false
  @callback accept_encoding_exists?(Plug.Conn.t) :: true | false
  @callback encoding_available?(Plug.Conn.t) :: true | false
  @callback processable?(Plug.Conn.t) :: true | false
  @callback exists?(Plug.Conn.t) :: true | false
  @callback method_put?(Plug.Conn.t) :: true | false
  @callback existed?(Plug.Conn.t) :: true | false
  @callback post_to_missing?(Plug.Conn.t) :: true | false
  @callback can_post_to_missing?(Plug.Conn.t) :: true | false
  @callback moved_permanently?(Plug.Conn.t) :: true | false
  @callback moved_temporarily?(Plug.Conn.t) :: true | false
  @callback post_to_gone?(Plug.Conn.t) :: true | false
  @callback can_post_to_gone?(Plug.Conn.t) :: true | false
  @callback method_put?(Plug.Conn.t) :: true | false
  @callback put_to_different_url?(Plug.Conn.t) :: true | false
  @callback can_put_to_missing?(Plug.Conn.t) :: true | false
  @callback if_none_match_exists?(Plug.Conn.t) :: true | false
  @callback if_none_match_star?(Plug.Conn.t) :: true | false
  @callback etag_matches_for_if_none?(Plug.Conn.t) :: true | false
  @callback if_none_match?(Plug.Conn.t) :: true | false
  @callback if_match_exists?(Plug.Conn.t) :: true | false
  @callback if_match_star?(Plug.Conn.t) :: true | false
  @callback etag_matches_for_if_match?(Plug.Conn.t) :: true | false
  @callback if_match_star_exists_for_missing?(Plug.Conn.t) :: true | false
  @callback etag_matches_for_if_match?(Plug.Conn.t) :: true | false
  @callback if_modified_since_exists?(Plug.Conn.t) :: true | false
  @callback if_modified_since_valid_date?(Plug.Conn.t) :: true | false
  @callback modified_since?(Plug.Conn.t) :: true | false
  @callback if_unmodified_since_exists?(Plug.Conn.t) :: true | false
  @callback if_unmodified_since_valid_date?(Plug.Conn.t) :: true | false
  @callback unmodified_since?(Plug.Conn.t) :: true | false
  @callback method_delete?(Plug.Conn.t) :: true | false
  @callback delete_enacted?(Plug.Conn.t) :: true | false
  @callback method_patch?(Plug.Conn.t) :: true | false
  @callback patch_enacted?(Plug.Conn.t) :: true | false
  @callback method_post?(Plug.Conn.t) :: true | false
  @callback post_redirect?(Plug.Conn.t) :: true | false
  @callback post_to_existing?(Plug.Conn.t) :: true | false
  @callback post_enacted?(Plug.Conn.t) :: true | false
  @callback put_to_existing?(Plug.Conn.t) :: true | false
  @callback put_enacted?(Plug.Conn.t) :: true | false
  @callback respond_with_entity?(Plug.Conn.t) :: true | false
  @callback multiple_representations?(Plug.Conn.t) :: true | false
  @callback conflict?(Plug.Conn.t) :: true | false
  @callback new?(Plug.Conn.t) :: true | false

  @callback delete!(Plug.Conn.t) :: nil
  @callback put!(Plug.Conn.t) :: nil
  @callback patch!(Plug.Conn.t) :: nil
  @callback post!(Plug.Conn.t) :: nil

  @callback handle_ok(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_options(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_created(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_accepted(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_no_content(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_multiple_representations(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_moved_permanently(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_see_other(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_not_modified(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_moved_temporarily(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_malformed(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unauthorized(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_forbidden(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_not_found(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_method_not_allowed(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_not_acceptable(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_conflict(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_gone(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_precondition_failed(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_request_entity_too_large(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_uri_too_long(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unsupported_media_type(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unprocessable_entity(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unknown_method(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_not_implemented(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_service_unavailable(Plug.Conn.t) :: Plug.Conn.t

  defmacro __using__(_opts) do
    quote do
      use Plug.Builder
      use Timex
      @behaviour Liberator.Resource

      plug :check_service_available
      plug :check_known_method
      plug :check_uri_too_long
      plug :check_method_allowed
      plug :check_malformed
      plug :check_authorized
      plug :check_allowed
      plug :check_valid_content_header
      plug :check_known_content_type
      plug :check_valid_entity_length
      plug :check_is_options
      plug :evaluate

      defp check_service_available(conn, _opts) do
        if result = service_available?(conn) do
          merge_map_assigns(conn, result)
        else
          conn
          |> handle_service_unavailable()
          |> halt()
        end
      end

      defp check_known_method(conn, _opts) do
        if result = known_method?(conn) do
          merge_map_assigns(conn, result)
        else
          conn
          |> handle_unknown_method()
          |> halt()
        end
      end

      defp check_uri_too_long(conn, _opts) do
        if result = uri_too_long?(conn) do
          conn
          |> merge_map_assigns(result)
          |> handle_uri_too_long()
          |> halt()
        else
          conn
        end
      end

      defp check_method_allowed(conn, _opts) do
        if result = method_allowed?(conn) do
          merge_map_assigns(conn, result)
        else
          conn
          |> handle_method_not_allowed()
          |> halt()
        end
      end

      defp check_malformed(conn, _opts) do
        if result = malformed?(conn) do
          conn
          |> merge_map_assigns(result)
          |> handle_malformed()
          |> halt()
        else
          conn
        end
      end

      defp check_authorized(conn, _opts) do
        if result = authorized?(conn) do
          merge_map_assigns(conn, result)
        else
          conn
          |> handle_unauthorized()
          |> halt()
        end
      end

      defp check_allowed(conn, _opts) do
        if result = allowed?(conn) do
          merge_map_assigns(conn, result)
        else
          conn
          |> handle_forbidden()
          |> halt()
        end
      end

      defp check_valid_content_header(conn, _opts) do
        if result = valid_content_header?(conn) do
          merge_map_assigns(conn, result)
        else
          conn
          |> handle_not_implemented()
          |> halt()
        end
      end

      defp check_known_content_type(conn, _opts) do
        if result = known_content_type?(conn) do
          merge_map_assigns(conn, result)
        else
          conn
          |> handle_unsupported_media_type()
          |> halt()
        end
      end

      defp check_valid_entity_length(conn, _opts) do
        if result = valid_entity_length?(conn) do
          merge_map_assigns(conn, result)
        else
          conn
          |> handle_request_entity_too_large()
          |> halt()
        end
      end

      defp check_is_options(conn, _opts) do
        if result = is_options?(conn) do
          conn
          |> merge_map_assigns(result)
          |> handle_options()
          |> halt()
        else
          conn
        end
      end

      defp merge_map_assigns(conn, result) do
        if is_map(result) do
          merge_assigns(conn, Enum.to_list(result))
        else
          conn
        end
      end

      defp evaluate(conn, _opts) do
        cond do
          accept_exists?(conn) and not media_type_available?(conn) ->
            handle_not_acceptable(conn)
          accept_language_exists?(conn) and not language_available?(conn) ->
            handle_not_acceptable(conn)
          accept_charset_exists?(conn) and not charset_available?(conn) ->
            handle_not_acceptable(conn)
          accept_encoding_exists?(conn) and not encoding_available?(conn) ->
            handle_not_acceptable(conn)
          not processable?(conn) ->
            handle_unprocessable_entity(conn)
          true ->
            if exists?(conn) do
              cond do
                if_match_exists?(conn) and not if_match_star?(conn) and not etag_matches_for_if_match?(conn) ->
                  handle_precondition_failed(conn)
                if_unmodified_since_exists?(conn) and if_unmodified_since_valid_date?(conn) and unmodified_since?(conn) ->
                  handle_precondition_failed(conn)
                if_none_match_exists?(conn) and (if_none_match_star?(conn) or etag_matches_for_if_none?(conn)) ->
                  if if_none_match?(conn) do
                    handle_not_modified(conn)
                  else
                    handle_precondition_failed(conn)
                  end
                if_modified_since_exists?(conn) and if_modified_since_valid_date?(conn) and not modified_since?(conn) ->
                  handle_not_modified(conn)
                method_delete?(conn) ->
                  delete!(conn)
                  if delete_enacted?(conn) do
                    finish_response(conn)
                  else
                    handle_accepted(conn)
                  end
                method_patch?(conn) ->
                  patch!(conn)
                  if patch_enacted?(conn) do
                    finish_response(conn)
                  else
                    handle_accepted(conn)
                  end
                post_to_existing?(conn) ->
                  from_conflict(conn)
                put_to_existing?(conn) ->
                  from_conflict(conn)
                true ->
                  handle_ok(conn)
              end
            else
              if if_match_star_exists_for_missing?(conn) do
                handle_precondition_failed(conn)
              else
                if method_put?(conn) do
                  if put_to_different_url?(conn) do
                    handle_moved_permanently(conn)
                  else
                    if can_put_to_missing?(conn) do
                      from_conflict(conn)
                    else
                      handle_not_implemented(conn)
                    end
                  end
                else
                  if existed?(conn) do
                    if moved_permanently?(conn) do
                      handle_moved_permanently(conn)
                    else
                      if moved_temporarily?(conn) do
                        handle_moved_temporarily(conn)
                      else
                        if post_to_gone?(conn) do
                          if can_post_to_gone?(conn) do
                            from_post(conn)
                          else
                            handle_gone(conn)
                          end
                        else
                          handle_gone(conn)
                        end
                      end
                    end
                  else
                    if post_to_missing?(conn) do
                      if can_post_to_missing?(conn) do
                        from_post(conn)
                      else
                        handle_not_found(conn)
                      end
                    else
                      handle_not_found(conn)
                    end
                  end
                end
              end
            end
        end
      end

      defp from_conflict(conn) do
        if conflict?(conn) do
          handle_conflict(conn)
        else
          if method_post?(conn) do
            from_post(conn)
          else
            from_put(conn)
          end
        end
      end

      defp from_post(conn) do
        post!(conn)

        if post_enacted?(conn) do
          if post_redirect?(conn) do
            handle_see_other(conn)
          else
            if new?(conn) do
              handle_created(conn)
            else
              finish_response(conn)
            end
          end
        else
          handle_accepted(conn)
        end
      end

      defp from_put(conn) do
        put!(conn)

        if put_enacted?(conn) do
          if new?(conn) do
            handle_created(conn)
          else
            finish_response(conn)
          end
        else
          handle_accepted(conn)
        end
      end

      defp finish_response(conn) do
        if respond_with_entity?(conn) do
          if multiple_representations?(conn) do
            handle_multiple_representations(conn)
          else
            handle_ok(conn)
          end
        else
          handle_no_content(conn)
        end
      end

      @impl true
      def allowed_methods(_conn) do
        ["GET", "HEAD"]
      end

      @impl true
      def available_media_types(_conn) do
        []
      end

      @impl true
      def available_languages(_conn) do
        ["*"]
      end

      @impl true
      def available_charsets(_conn) do
        ["UTF-8"]
      end

      @impl true
      def available_encodings(_conn) do
        ["identity"]
      end

      @impl true
      def last_modified(_conn) do
        DateTime.utc_now()
      end

      @impl true
      def etag(_conn) do
        nil
      end

      @impl true
      def service_available?(_conn), do: true
      @impl true
      def known_method?(conn) do
        conn.method in ["GET", "HEAD", "OPTIONS", "PUT", "POST", "DELETE", "PATCH", "TRACE"]
      end
      @impl true
      def uri_too_long?(_conn), do: false
      @impl true
      def method_allowed?(conn) do
        conn.method in allowed_methods(conn)
      end
      @impl true
      def malformed?(_conn), do: false
      @impl true
      def authorized?(_conn), do: true
      @impl true
      def allowed?(_conn), do: true
      @impl true
      def valid_content_header?(_conn), do: true
      @impl true
      def known_content_type?(_conn), do: true
      @impl true
      def valid_entity_length?(_conn), do: true
      @impl true

      @impl true
      def is_options?(conn), do: conn.method == "OPTIONS"
      @impl true
      def method_put?(conn), do: conn.method == "PUT"
      @impl true
      def method_post?(conn), do: conn.method == "POST"
      @impl true
      def method_delete?(conn), do: conn.method == "DELETE"
      @impl true
      def method_patch?(conn), do: conn.method == "PATCH"

      @impl true
      def accept_exists?(conn) do
        get_req_header(conn, "accept") |> Enum.any?()
      end
      @impl true
      def accept_language_exists?(conn) do
        get_req_header(conn, "accept-language") |> Enum.any?()
      end
      @impl true
      def accept_charset_exists?(conn) do
        get_req_header(conn, "accept-charset") |> Enum.any?()
      end
      @impl true
      def accept_encoding_exists?(conn) do
        get_req_header(conn, "accept-encoding") |> Enum.any?()
      end

      @impl true
      def media_type_available?(conn) do
        requested_media_type = get_req_header(conn, "accept") |> Enum.at(0)
        (requested_media_type in available_media_types(conn)) or requested_media_type == "*/*"
      end
      @impl true
      def language_available?(conn) do
        available_langs = available_languages(conn)
        ("*" in available_langs) or
        Enum.zip(available_langs, get_req_header(conn, "accept-language"))
        |> Enum.any?(fn {av, req} -> String.starts_with?(req, av) end)
      end
      @impl true
      def charset_available?(_conn), do: true
      @impl true
      def encoding_available?(_conn), do: true

      @impl true
      def processable?(_conn), do: true
      @impl true
      def exists?(_conn), do: true
      @impl true
      def existed?(_conn), do: false
      @impl true
      def moved_permanently?(_conn), do: false
      @impl true
      def moved_temporarily?(_conn), do: false

      @impl true
      def if_match_star_exists_for_missing?(_conn), do: false
      @impl true
      def post_to_missing?(_conn), do: true
      @impl true
      def post_to_existing?(_conn), do: false
      @impl true
      def post_to_gone?(_conn), do: false
      @impl true
      def can_post_to_missing?(_conn), do: true
      @impl true
      def can_post_to_gone?(_conn), do: false
      @impl true
      def put_to_existing?(_conn), do: false
      @impl true
      def can_put_to_missing?(_conn), do: false
      @impl true
      def put_to_different_url?(_conn), do: false

      @impl true
      def if_match_exists?(conn) do
        get_req_header(conn, "if-match") |> Enum.any?()
      end
      @impl true
      def if_match_star?(conn) do
        get_req_header(conn, "if-match") |> Enum.any?(&(&1 == "*"))
      end
      @impl true
      def if_none_match_exists?(conn) do
        get_req_header(conn, "if-none-match") |> Enum.any?()
      end
      @impl true
      def if_none_match_star?(conn) do
        get_req_header(conn, "if-none-match") |> Enum.any?(&(&1 == "*"))
      end
      @impl true
      def if_none_match?(_conn), do: false
      @impl true
      def etag_matches_for_if_match?(conn) do
        if etag = etag(conn) do
          etag == get_req_header(conn, "if-match") |> Enum.at(0)
        else
          false
        end
      end
      @impl true
      def etag_matches_for_if_none?(conn) do
        if etag = etag(conn) do
          etag == get_req_header(conn, "if-none-match") |> Enum.at(0)
        else
          false
        end
      end

      @impl true
      def if_modified_since_exists?(conn) do
        get_req_header(conn, "if-modified-since") |> Enum.any?()
      end
      @impl true
      def if_modified_since_valid_date?(conn) do
        conn
        |> get_req_header("if-modified-since")
        |> Enum.at(0)
        |> Timex.parse("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
        |> case do
          {:ok, _time} -> true
          _ -> false
        end
      end
      @impl true
      def modified_since?(conn) do
        conn
        |> get_req_header("if-modified-since")
        |> Enum.at(0)
        |> Timex.parse!("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
        |> Timex.before?(last_modified(conn))
      end
      @impl true
      def if_unmodified_since_exists?(conn) do
        get_req_header(conn, "if-unmodified-since") |> Enum.any?()
      end
      @impl true
      def if_unmodified_since_valid_date?(conn) do
        conn
        |> get_req_header("if-unmodified-since")
        |> Enum.at(0)
        |> Timex.parse("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
        |> case do
          {:ok, _time} -> true
          _ -> false
        end
      end
      @impl true
      def unmodified_since?(conn) do
        conn
        |> get_req_header("if-unmodified-since")
        |> Enum.at(0)
        |> Timex.parse!("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
        |> Timex.after?(last_modified(conn))
      end

      @impl true
      def post_redirect?(_conn), do: false
      @impl true
      def post_enacted?(_conn), do: true
      @impl true
      def put_enacted?(_conn), do: true
      @impl true
      def delete_enacted?(_conn), do: true
      @impl true
      def patch_enacted?(_conn), do: true
      @impl true
      def respond_with_entity?(_conn), do: true
      @impl true
      def conflict?(_conn), do: false
      @impl true
      def new?(_conn), do: true
      @impl true
      def multiple_representations?(_conn), do: false


      @impl true
      def delete!(_conn) do
        nil
      end

      @impl true
      def put!(_conn) do
        nil
      end

      @impl true
      def patch!(_conn) do
        nil
      end

      @impl true
      def post!(_conn) do
        nil
      end


      @impl true
      def handle_ok(conn) do
        send_resp(conn, 200, "OK")
      end

      @impl true
      def handle_options(conn) do
        send_resp(conn, 200, "Options")
      end

      @impl true
      def handle_created(conn) do
        send_resp(conn, 201, "Created")
      end

      @impl true
      def handle_accepted(conn) do
        send_resp(conn, 202, "Accepted")
      end

      @impl true
      def handle_no_content(conn) do
        send_resp(conn, 204, "No Content")
      end

      @impl true
      def handle_multiple_representations(conn) do
        send_resp(conn, 300, "Multiple Representations")
      end

      @impl true
      def handle_moved_permanently(conn) do
        send_resp(conn, 301, "Moved Permanently")
      end

      @impl true
      def handle_see_other(conn) do
        send_resp(conn, 303, "See Other")
      end

      @impl true
      def handle_not_modified(conn) do
        send_resp(conn, 304, "Not Modified")
      end

      @impl true
      def handle_moved_temporarily(conn) do
        send_resp(conn, 307, "Moved Temporarily")
      end

      @impl true
      def handle_malformed(conn) do
        send_resp(conn, 400, "Malformed")
      end

      @impl true
      def handle_unauthorized(conn) do
        send_resp(conn, 401, "Unauthorized")
      end

      @impl true
      def handle_forbidden(conn) do
        send_resp(conn, 403, "Forbidden")
      end

      @impl true
      def handle_not_found(conn) do
        send_resp(conn, 404, "Not Found")
      end

      @impl true
      def handle_method_not_allowed(conn) do
        send_resp(conn, 405, "Method Not Allowed")
      end

      @impl true
      def handle_not_acceptable(conn) do
        send_resp(conn, 406, "Not Acceptable")
      end

      @impl true
      def handle_conflict(conn) do
        send_resp(conn, 409, "Conflict")
      end

      @impl true
      def handle_gone(conn) do
        send_resp(conn, 410, "Gone")
      end

      @impl true
      def handle_precondition_failed(conn) do
        send_resp(conn, 412, "Precondition Failed")
      end

      @impl true
      def handle_request_entity_too_large(conn) do
        send_resp(conn, 413, "Request Entity Too Large")
      end

      @impl true
      def handle_uri_too_long(conn) do
        send_resp(conn, 414, "URI Too Long")
      end

      @impl true
      def handle_unsupported_media_type(conn) do
        send_resp(conn, 415, "Unsupported Media Type")
      end

      @impl true
      def handle_unprocessable_entity(conn) do
        send_resp(conn, 422, "Unprocessable Entity")
      end

      @impl true
      def handle_not_implemented(conn) do
        send_resp(conn, 501, "Not Implemented")
      end

      @impl true
      def handle_unknown_method(conn) do
        send_resp(conn, 501, "Unknown Method")
      end

      @impl true
      def handle_service_unavailable(conn) do
        send_resp(conn, 503, "Service Unavailable")
      end

      defoverridable Liberator.Resource
    end
  end
end
