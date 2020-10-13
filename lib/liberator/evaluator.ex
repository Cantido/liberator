defmodule Liberator.Evaluator do
  alias Liberator.Trace
  import Plug.Conn

  @moduledoc false

  @decisions %{
    service_available?: {:known_method?, :handle_service_unavailable},
    known_method?: {:uri_too_long?, :handle_unknown_method},
    uri_too_long?: {:handle_uri_too_long, :method_allowed?},
    method_allowed?: {:malformed?, :handle_method_not_allowed},
    malformed?: {:handle_malformed, :authorized?},
    authorized?: {:allowed?, :handle_unauthorized},
    allowed?: {:too_many_requests?, :handle_forbidden},
    too_many_requests?: {:handle_too_many_requests, :payment_required?},
    payment_required?: {:handle_payment_required, :valid_content_header?},
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
    processable?: {:unavailable_for_legal_reasons?, :handle_unprocessable_entity},
    unavailable_for_legal_reasons?: {:handle_unavailable_for_legal_reasons, :exists?},
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
    initialize: :service_available?,
    delete!: :delete_enacted?,
    put!: :put_enacted?,
    patch!: :patch_enacted?,
    post!: :post_enacted?
  }

  @handlers %{
    handle_ok: 200,
    handle_options: 200,
    handle_created: 201,
    handle_accepted: 202,
    handle_no_content: 204,
    handle_multiple_representations: 300,
    handle_moved_permanently: 301,
    handle_see_other: 303,
    handle_not_modified: 304,
    handle_moved_temporarily: 307,
    handle_malformed: 400,
    handle_unauthorized: 401,
    handle_payment_required: 402,
    handle_forbidden: 403,
    handle_not_found: 404,
    handle_method_not_allowed: 405,
    handle_not_acceptable: 406,
    handle_conflict: 409,
    handle_gone: 410,
    handle_precondition_failed: 412,
    handle_request_entity_too_large: 413,
    handle_uri_too_long: 414,
    handle_unsupported_media_type: 415,
    handle_unprocessable_entity: 422,
    handle_too_many_requests: 429,
    handle_unavailable_for_legal_reasons: 451,
    handle_unknown_method: 501,
    handle_not_implemented: 501,
    handle_service_unavailable: 503
  }

  @mediatype_codecs %{
    "text/plain" => Liberator.MediaType.TextPlainCodec,
    "application/json" => Jason
  }

  @compression_codecs %{
    "identity" => Liberator.Encoding.Identity,
    "deflate" => Liberator.Encoding.Deflate,
    "gzip" => Liberator.Encoding.Gzip
  }

  def init(opts), do: opts

  def call(conn, opts) do
    module = Keyword.get(opts, :module)
    continue(conn, module, :initialize, opts)
  end

  defp continue(conn, module, next_step, opts) do
    cond do
      Map.has_key?(@decisions, next_step) ->
        {true_step, false_step} = @decisions[next_step]

        if result = apply(module, next_step, [conn]) do
          conn = merge_map_assigns(conn, result)
          conn = Trace.update_trace(conn, next_step, result)
          continue(conn, module, true_step, opts)
        else
          conn = Trace.update_trace(conn, next_step, result)
          continue(conn, module, false_step, opts)
        end

      Map.has_key?(@actions, next_step) ->
        conn = Trace.update_trace(conn, next_step, nil)

        apply(module, next_step, [conn])
        continue(conn, module, @actions[next_step], opts)

      Map.has_key?(@handlers, next_step) ->
        conn = Trace.update_trace(conn, next_step, nil)

        conn =
          if Keyword.get(opts, :trace) == :headers do
            trace =
              Trace.get_trace(conn)
              |> Enum.map(fn {key, val} ->
                {"x-liberator-trace", "#{Atom.to_string(key)}: #{inspect(val)}"}
              end)

            prepend_resp_headers(conn, trace)
          else
            conn
          end

        conn = apply_retry_header(conn)

        status = @handlers[next_step]
        body = apply(module, next_step, [conn])

        content_type = Map.get(conn.assigns, :media_type, "text/plain")
        mediatype_codec = get_mediatype_codec(content_type)
        encoded_body = mediatype_codec.encode!(body)
        conn = put_resp_header(conn, "content-type", content_type)

        content_encoding = Map.get(conn.assigns, :encoding, "identity")
        compression_codec = get_compression_codec(content_encoding)
        compressed_body = compression_codec.encode!(encoded_body)
        conn = put_resp_header(conn, "content-encoding", content_encoding)

        send_resp(conn, status, compressed_body)

      true ->
        raise "Unknown step #{inspect(next_step)}"
    end
  end

  defp apply_retry_header(conn) do
    if retry_after = Map.get(conn.assigns, :retry_after) do
      retry_after_value =
        cond do
          Timex.is_valid?(retry_after) ->
            Liberator.HTTPDateTime.format!(retry_after)

          is_integer(retry_after) ->
            Integer.to_string(retry_after)

          String.valid?(retry_after) ->
            retry_after

          true ->
            raise "Value for :retry_after was not a valid DateTime, integer, or String, but was #{inspect retry_after}. " <>
              "Make sure the too_many_requests/1 function of #{inspect module} is setting that key to one of those types. " <>
              "Remember that you can also just return true or false."
        end

      put_resp_header(conn, "retry-after", retry_after_value)
    else
      conn
    end
  end

  defp get_mediatype_codec(media_type) do
    Application.get_env(:liberator, :media_types, @mediatype_codecs)
    |> Map.get(media_type)
    |> case do
      nil ->
        raise "No codec found for media type #{media_type}. " <>
                " Add a codec module to the :media_types map under the :liberator config in config.exs."

      codec ->
        codec
    end
  end

  defp get_compression_codec(encoding) do
    Application.get_env(:liberator, :encodings, @compression_codecs)
    |> Map.get(encoding)
    |> case do
      nil ->
        raise "No codec found for encoding #{encoding}. " <>
                "Add a codec module to the :encodings map under the :liberator config in config.exs."

      codec ->
        codec
    end
  end

  defp merge_map_assigns(conn, result) do
    if is_map(result) do
      merge_assigns(conn, Enum.to_list(result))
    else
      conn
    end
  end
end
