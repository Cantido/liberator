defmodule LiberatorEx.Resource do
  import Plug.Conn
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

  def init(options) do
    # initialize options
    options
  end

  def call(conn, opts) do
    handler_module = Keyword.get(opts, :handler, LiberatorEx.Base)

    cond do
      not handler_module.service_available?(conn) ->
        send_resp(conn, 503, Jason.encode!([]))
      not handler_module.known_method?(conn) ->
        send_resp(conn, 501, Jason.encode!([]))
      handler_module.uri_too_long?(conn) ->
        send_resp(conn, 414, Jason.encode!([]))
      not handler_module.method_allowed?(conn) ->
        send_resp(conn, 405, Jason.encode!([]))
      handler_module.malformed?(conn) ->
        send_resp(conn, 400, Jason.encode!([]))
      not handler_module.authorized?(conn) ->
        send_resp(conn, 401, Jason.encode!([]))
      not handler_module.allowed?(conn) ->
        send_resp(conn, 403, Jason.encode!([]))
      not handler_module.valid_content_header?(conn) ->
        send_resp(conn, 501, Jason.encode!([]))
      not handler_module.known_content_type?(conn) ->
        send_resp(conn, 415, Jason.encode!([]))
      not handler_module.valid_entity_length?(conn) ->
        send_resp(conn, 413, Jason.encode!([]))
      true ->
        send_resp(conn, 200, Jason.encode!([]))
    end
  end
end
