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

      @decisions %{
        service_available?: {:known_method?, :handle_service_unavailable},
        known_method?: {:uri_too_long?, :handle_unknown_method},
        uri_too_long?: {:handle_uri_too_long, :method_allowed?},
        method_allowed?: {:malformed?, :handle_method_not_allowed},
        malformed?: {:handle_malformed, :authorized?},
        authorized?: {:allowed?, :handle_unauthorized},
        allowed?: {:valid_content_header?, :handle_forbidden},
        valid_content_header?: {:known_content_type?, :handle_not_implemented},
        known_content_type?: {:valid_entity_length?, :handle_unsupported_media_type},
        valid_entity_length?: {:is_options?, :handle_request_entity_too_large},
        is_options?: {:handle_options, :accept_exists?},
        accept_exists?: {:media_type_available?, :accept_language_exists?},
        media_type_available?: {:accept_language_exists?, :handle_not_acceptable},
        accept_language_exists?: {:language_available?, :accept_charset_exists?},
        language_available?: {:accept_charset_exists?, :handle_not_acceptable},
        accept_charset_exists?: {:charset_available?, :accept_encoding_exists?},
        charset_available?: {:accept_encoding_exists?, :handle_not_acceptable},
        accept_encoding_exists?: {:encoding_available?, :processable?},
        encoding_available?: {:processable?, :handle_not_acceptable},
        processable?: {:exists?, :handle_unprocessable_entity},
        exists?: {:if_match_exists?, :if_match_star_exists_for_missing?},
        if_match_exists?: {:if_match_star?, :if_unmodified_since_exists?},
        if_match_star?: {:if_unmodified_since_exists?, :etag_matches_for_if_match?},
        etag_matches_for_if_match?: {:if_unmodified_since_exists?, :handle_precondition_failed},
        if_unmodified_since_exists?: {:if_unmodified_since_valid_date?, :if_none_match_exists?},
        if_unmodified_since_valid_date?: {:unmodified_since?, :if_none_match_exists?},
        unmodified_since?: {:handle_precondition_failed, :if_none_match_exists?},
        if_none_match_exists?: {:if_none_match_star?, :if_modified_since_exists?},
        if_none_match_star?: {:if_none_match?, :etag_matches_for_if_none?},
        etag_matches_for_if_none?: {:if_none_match?, :if_modified_since_exists?},
        if_none_match?: {:handle_not_modified, :handle_precondition_failed},
        if_modified_since_exists?: {:if_modified_since_valid_date?, :method_delete?},
        if_modified_since_valid_date?: {:modified_since?, :method_delete?},
        modified_since?: {:method_delete?, :handle_not_modified},
        if_match_star_exists_for_missing?: {:handle_precondition_failed, :method_put?},
        method_put?: {:put_to_different_url?, :existed?},
        put_to_different_url?: {:handle_moved_permanently, :can_put_to_missing?},
        can_put_to_missing?: {:conflict?, :handle_not_implemented},
        existed?: {:moved_permanently?, :post_to_missing?},
        moved_permanently?: {:handle_moved_permanently, :moved_temporarily?},
        moved_temporarily?: {:handle_moved_temporarily, :post_to_gone?},
        post_to_gone?: {:can_post_to_gone?, :handle_gone},
        can_post_to_gone?: {:post!, :handle_gone},
        post_to_missing?: {:can_post_to_missing?, :handle_not_found},
        can_post_to_missing?: {:post!, :handle_not_found},
        method_delete?: {:delete!, :method_patch?},
        method_patch?: {:patch!, :post_to_existing?},
        post_to_existing?: {:conflict?, :put_to_existing?},
        put_to_existing?: {:conflict?, :multiple_representations?},
        conflict?: {:handle_conflict, :method_post?},
        method_post?: {:post!, :put!},
        delete_enacted?: {:respond_with_entity?, :handle_accepted},
        put_enacted?: {:new?, :handle_accepted},
        patch_enacted?: {:respond_with_entity?, :handle_accepted},
        post_enacted?: {:post_redirect?, :handle_accepted},
        post_redirect?: {:handle_see_other, :new?},
        new?: {:handle_created, :respond_with_entity?},
        respond_with_entity?: {:multiple_representations?, :handle_no_content},
        multiple_representations?: {:handle_multiple_representations, :handle_ok}
      }

      @actions %{
        delete!: :delete_enacted?,
        put!: :put_enacted?,
        patch!: :patch_enacted?,
        post!: :post_enacted?
      }

      @handlers %{
        handle_ok: %{},
        handle_options: %{},
        handle_created: %{},
        handle_accepted: %{},
        handle_no_content: %{},
        handle_multiple_representations: %{},
        handle_moved_permanently: %{},
        handle_see_other: %{},
        handle_not_modified: %{},
        handle_moved_temporarily: %{},
        handle_malformed: %{},
        handle_unauthorized: %{},
        handle_forbidden: %{},
        handle_not_found: %{},
        handle_method_not_allowed: %{},
        handle_not_acceptable: %{},
        handle_conflict: %{},
        handle_gone: %{},
        handle_precondition_failed: %{},
        handle_request_entity_too_large: %{},
        handle_uri_too_long: %{},
        handle_unsupported_media_type: %{},
        handle_unprocessable_entity: %{},
        handle_unknown_method: %{},
        handle_not_implemented: %{},
        handle_service_unavailable: %{}
      }

      plug :start

      defp start(conn, opts) do
        continue(conn, :service_available?, opts)
      end

      defp continue(conn, next_step, opts) do
        cond do
          Map.has_key?(@decisions, next_step) ->
            {true_step, false_step} = @decisions[next_step]
            if result = apply(__MODULE__, next_step, [conn]) do
              conn = merge_map_assigns(conn, result)
              continue(conn, true_step, opts)
            else
              continue(conn, false_step, opts)
            end
          Map.has_key?(@actions, next_step) ->
            apply(__MODULE__, next_step, [conn])
            continue(conn, @actions[next_step], opts)
          Map.has_key?(@handlers, next_step) ->
            apply(__MODULE__, next_step, [conn])
          true ->
            raise "Unknown step #{inspect next_step}"
        end
      end

      defp merge_map_assigns(conn, result) do
        if is_map(result) do
          merge_assigns(conn, Enum.to_list(result))
        else
          conn
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
      def if_match_star_exists_for_missing?(conn), do: if_match_star?(conn)
      @impl true
      def post_to_missing?(conn), do: method_post?(conn)
      @impl true
      def post_to_existing?(conn), do: method_post?(conn)
      @impl true
      def post_to_gone?(conn), do: method_post?(conn)
      @impl true
      def can_post_to_missing?(_conn), do: true
      @impl true
      def can_post_to_gone?(_conn), do: false
      @impl true
      def put_to_existing?(conn), do: method_put?(conn)
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
