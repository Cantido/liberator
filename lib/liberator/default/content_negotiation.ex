defmodule Liberator.Default.ContentNegotiation do
  import Plug.Conn
  @moduledoc false

  def media_type_available?(module, conn) do
    accept_something(
      conn,
      :media_type,
      "accept",
      apply(module, :available_media_types, [conn]),
      "*/*"
    )
  end

  def language_available?(module, conn) do
    assigns =
      accept_something(
        conn,
        :language,
        "accept-language",
        apply(module, :available_languages, [conn])
      )

    language =
      if is_map(assigns) do
        Map.get(assigns, :language)
      else
        nil
      end

    unless is_nil(language) or language == "*" do
      assigns.language
      |> String.replace("-", "_")
      |> Gettext.put_locale()
    end

    assigns
  end

  def charset_available?(module, conn) do
    accept_something(
      conn,
      :charset,
      "accept-charset",
      apply(module, :available_charsets, [conn])
    )
  end

  def encoding_available?(module, conn) do
    accept_something(
      conn,
      :encoding,
      "accept-encoding",
      apply(module, :available_encodings, [conn])
    )
  end

  defp accept_something(conn, key, header_name, available_values, wildcard \\ "*") do
    vals =
      get_req_header(conn, header_name)
      |> Enum.flat_map(&String.split(&1, ","))
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn hdr ->
        case String.split(hdr, ";") do
          [type] -> {type, %{"q" => "1.0"}}
          [type | params] -> {type, parse_params(params)}
        end
      end)
      |> product(available_values)
      |> Enum.filter(fn {{req, _params}, av} ->
        req == av or req == wildcard or av == wildcard
      end)
      |> Enum.map(fn {req, _av} -> req end)

    if Enum.any?(vals) do
      {type, _params} =
        Enum.max_by(vals, fn {_type, params} ->
          params
          |> Map.get("q", "1.0")
          |> Float.parse()
          |> case do
            {q, ""} -> q
            _ -> 0.0
          end
        end)

      if type == wildcard do
        default_type = Enum.at(available_values, 0)
        Map.new([{key, default_type}])
      else
        Map.new([{key, type}])
      end
    else
      false
    end
  end

  defp parse_params(params) do
    params
    |> Enum.map(&parse_param/1)
    |> Map.new()
  end

  defp parse_param(param) do
    param
    |> String.split("=")
    |> case do
      [param, val] -> {param, val}
    end
  end

  defp product(a, b) do
    Enum.flat_map(a, fn i ->
      Enum.map(b, fn j ->
        {i, j}
      end)
    end)
  end
end
