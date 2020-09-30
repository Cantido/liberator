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

  @callback handle_ok(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_options(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_malformed(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_unauthorized(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_forbidden(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_method_not_allowed(Plug.Conn.t) :: Plug.Conn.t
  @callback handle_not_acceptable(Plug.Conn.t) :: Plug.Conn.t
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
        handler_module.handle_ok(conn)
    end
  end
end
