defmodule LiberatorEx.Resource do
  @moduledoc """
  Documentation for LiberatorEx.Resource.
  """

  @callback service_available?(Plug.Conn.t) :: true | false
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
  @callback if_match_star_exists_for_missing?(Plug.Conn.t) :: true | false
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
  @callback if_match_star?(Plug.Conn.t) :: true | false
  @callback if_none_match_exists?(Plug.Conn.t) :: true | false
  @callback etag_matches_for_if_match?(Plug.Conn.t) :: true | false
  @callback if_modified_since_exists?(Plug.Conn.t) :: true | false
  @callback if_unmodified_since_exists?(Plug.Conn.t) :: true | false
  @callback method_delete?(Plug.Conn.t) :: true | false
  @callback method_patch?(Plug.Conn.t) :: true | false
  @callback post_to_existing?(Plug.Conn.t) :: true | false
  @callback put_to_existing?(Plug.Conn.t) :: true | false
  @callback multiple_representations?(Plug.Conn.t) :: true | false
  @callback if_match_exists?(Plug.Conn.t) :: true | false
  @callback if_match_star?(Plug.Conn.t) :: true | false
  @callback etag_matches_for_if_match?(Plug.Conn.t) :: true | false

  @callback handle_ok(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_options(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_moved_permanently(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_moved_temporarily(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_malformed(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unauthorized(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_forbidden(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_not_found(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_method_not_allowed(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_not_acceptable(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_gone(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_precondition_failed(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_request_entity_too_large(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_uri_too_long(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unsupported_media_type(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unprocessable_entity(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unknown_method(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_not_implemented(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_service_unavailable(Plug.Conn.t) :: Plug.Conn.t

  def init(options) do
    # initialize options
    options
  end

  def call(conn, opts) do
    handler_module = Keyword.get(opts, :handler, LiberatorEx.Base)

    cond do
      not handler_module.service_available?(conn) ->
        handler_module.handle_service_unavailable(conn)
      not handler_module.known_method?(conn) ->
        handler_module.handle_unknown_method(conn)
      handler_module.uri_too_long?(conn) ->
        handler_module.handle_uri_too_long(conn)
      not handler_module.method_allowed?(conn) ->
        handler_module.handle_method_not_allowed(conn)
      handler_module.malformed?(conn) ->
        handler_module.handle_malformed(conn)
      not handler_module.authorized?(conn) ->
        handler_module.handle_unauthorized(conn)
      not handler_module.allowed?(conn) ->
        handler_module.handle_forbidden(conn)
      not handler_module.valid_content_header?(conn) ->
        handler_module.handle_not_implemented(conn)
      not handler_module.known_content_type?(conn) ->
        handler_module.handle_unsupported_media_type(conn)
      not handler_module.valid_entity_length?(conn) ->
        handler_module.handle_request_entity_too_large(conn)
      handler_module.is_options?(conn) ->
        handler_module.handle_options(conn)
      handler_module.accept_exists?(conn) and not handler_module.media_type_available?(conn) ->
        handler_module.handle_not_acceptable(conn)
      handler_module.accept_language_exists?(conn) and not handler_module.language_available?(conn) ->
        handler_module.handle_not_acceptable(conn)
      handler_module.accept_charset_exists?(conn) and not handler_module.charset_available?(conn) ->
        handler_module.handle_not_acceptable(conn)
      handler_module.accept_encoding_exists?(conn) and not handler_module.encoding_available?(conn) ->
        handler_module.handle_not_acceptable(conn)
      not handler_module.processable?(conn) ->
        handler_module.handle_unprocessable_entity(conn)
      true ->
        if handler_module.exists?(conn) do
          if handler_module.if_match_exists?(conn) and not handler_module.if_match_star?(conn) and not handler_module.etag_matches_for_if_match?(conn) do
            handler_module.handle_precondition_failed(conn)
          else
            # TODO
            handler_module.handle_ok(conn)
          end
        else
          if handler_module.if_match_star_exists_for_missing?(conn) do
            handler_module.handle_precondition_failed(conn)
          else
            if handler_module.method_put?(conn) do
              if handler_module.put_to_different_url?(conn) do
                handler_module.handle_moved_permanently(conn)
              else
                if handler_module.can_put_to_missing?(conn) do
                  # TODO
                else
                  handler_module.handle_not_implemented(conn)
                end
              end
            else
              if handler_module.existed?(conn) do
                if handler_module.moved_permanently?(conn) do
                  handler_module.handle_moved_permanently(conn)
                else
                  if handler_module.moved_temporarily?(conn) do
                    handler_module.handle_moved_temporarily(conn)
                  else
                    if handler_module.post_to_gone?(conn) do
                      if handler_module.can_post_to_gone?(conn) do
                        # TODO
                      else
                        handler_module.handle_gone(conn)
                      end
                    else
                      handler_module.handle_gone(conn)
                    end
                  end
                end
              else
                if handler_module.post_to_missing?(conn) do
                  if handler_module.can_post_to_missing?(conn) do
                    # TODO
                  else
                    handler_module.handle_not_found(conn)
                  end
                else
                  handler_module.handle_not_found(conn)
                end
              end
            end
          end
        end
    end
  end
end
