defmodule Liberator.Evaluator do
  alias Liberator.Trace
  alias Liberator.HTTPDateTime
  import Plug.Conn

  @moduledoc false

  @mediatype_codecs %{
    "text/plain" => Liberator.MediaType.TextPlain,
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

    :telemetry.span(
      [:liberator, :request],
      %{
        request_path: conn.request_path,
        request_id: Logger.metadata[:request_id]
        },
      fn ->
        conn =
          conn
          |> Trace.start(DateTime.utc_now())
          |> continue(module, :initialize, opts)
        {conn, %{metadata: Trace.get_trace(conn)}}
      end
    )
  end

  defp continue(conn, module, next_step, opts) do
    decisions = apply(module, :decisions, [])
    handlers = apply(module, :handlers, [])
    actions = apply(module, :actions, [])

    cond do
      Map.has_key?(decisions, next_step) ->
        called_at = DateTime.utc_now()
        {duration, result} = :timer.tc(module, next_step, [conn])
        conn = Trace.update_trace(conn, next_step, result, called_at, duration)

        {true_step, false_step} = decisions[next_step]

        if result do
          conn = handle_decision_result(conn, result)
          continue(conn, module, true_step, opts)
        else
          continue(conn, module, false_step, opts)
        end

      Map.has_key?(actions, next_step) ->
        called_at = DateTime.utc_now()
        {duration, result} = :timer.tc(module, next_step, [conn])

        conn
        |> Trace.update_trace(next_step, result, called_at, duration)
        |> handle_decision_result(result)
        |> continue(module, actions[next_step], opts)

      Map.has_key?(handlers, next_step) ->
        called_at = DateTime.utc_now()
        {duration, result} = :timer.tc(module, next_step, [conn])

        status = handlers[next_step]
        content_type = Map.get(conn.assigns, :media_type, "text/plain")
        content_encoding = Map.get(conn.assigns, :encoding, "identity")

        encoded_body =
          result
          |> encode_media_type!(content_type)
          |> encode_compression!(content_encoding)

        conn
        |> apply_allow_header(module)
        |> apply_retry_header(module)
        |> apply_last_modified_header(module)
        |> apply_etag(module)
        |> apply_location_header()
        |> put_resp_header("content-type", content_type)
        |> put_resp_header("content-encoding", content_encoding)
        |> put_resp_header("vary", "accept, accept-encoding, accept-language")
        |> Trace.update_trace(next_step, nil, called_at, duration)
        |> Trace.stop(DateTime.utc_now())
        |> do_trace(Keyword.get(opts, :trace))
        |> send_resp(status, encoded_body)
      true ->
        raise Liberator.UnknownStep, {next_step, module}
    end
  end

  defp do_trace(conn, trace_opt) do
    cond do
      trace_opt == :headers ->
        trace =
          conn
          |> Trace.get_trace()
          |> Trace.headers()

        prepend_resp_headers(conn, trace)
      trace_opt == :log ->
        conn
        |> Trace.get_trace()
        |> Trace.log(conn.request_path, Logger.metadata[:request_id])

        conn
      true ->
        conn
    end
  end

  defp apply_allow_header(conn, module) do
    put_resp_header(conn, "allow", Enum.join(module.allowed_methods(conn), ", "))
  end

  defp apply_retry_header(conn, module) do
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
            raise Liberator.InvalidRetryAfterValue, {retry_after, module}
        end

      put_resp_header(conn, "retry-after", retry_after_value)
    else
      conn
    end
  end

  defp apply_last_modified_header(conn, module) do
    last_modified_result = module.last_modified(conn)
    try do
      HTTPDateTime.format!(last_modified_result)
    rescue
      ArgumentError ->
        raise Liberator.InvalidLastModifiedValue, {last_modified_result, module}
    else
      formatted ->
        put_resp_header(conn, "last-modified", formatted)
    end
  end

  defp apply_etag(conn, module) do
    if etag = module.etag(conn) do
      put_resp_header(conn, "etag", <<?">> <> to_string(etag) <> <<?">>)
    else
      conn
    end
  end

  defp apply_location_header(conn) do
    if location = Map.get(conn.assigns, :location) do
      put_resp_header(conn, "location", location)
    else
      conn
    end
  end

  defp get_mediatype_codec(media_type) do
    Application.get_env(:liberator, :media_types, @mediatype_codecs)
    |> Map.get(media_type)
    |> case do
      nil ->
        raise Liberator.MediaTypeCodecNotFound, media_type
      codec ->
        codec
    end
  end

  defp encode_media_type!(body, media_type) do
    mediatype_codec = get_mediatype_codec(media_type)
    encoded_body = mediatype_codec.encode!(body)

    unless is_binary(encoded_body) do
      raise Liberator.MediaTypeCodecInvalidResult, {mediatype_codec, encoded_body}
    end
    encoded_body
  end

  defp get_compression_codec(encoding) do
    Application.get_env(:liberator, :encodings, @compression_codecs)
    |> Map.get(encoding)
    |> case do
      nil ->
        raise Liberator.CompressionCodecNotFound, encoding
      codec ->
        codec
    end
  end

  defp encode_compression!(body, content_encoding) do
    compression_codec = get_compression_codec(content_encoding)
    compressed_body = compression_codec.encode!(body)

    unless is_binary(compressed_body) do
      raise Liberator.CompressionCodecInvalidResult, {compression_codec, compressed_body}
    end
    compressed_body
  end

  defp handle_decision_result(_conn, %Plug.Conn{} = result) do
    result
  end

  defp handle_decision_result(conn, result) when is_map(result) do
    merge_assigns(conn, Enum.to_list(result))
  end

  defp handle_decision_result(conn, _result) do
    conn
  end
end
