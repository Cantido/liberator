defmodule Liberator.ResourceCodecTest do
  # Not async because some of these tests must manipulate the Application config
  use ExUnit.Case
  use Plug.Test

  test "if a media type codec does not return a binary, throws an exception with a nice message" do
    defmodule BrokenMediaType do
      def encode!(_), do: %{a: 1, b: 2}
    end

    media_types = Application.fetch_env!(:liberator, :media_types)
    on_exit(fn ->
      Application.put_env(:liberator, :media_types, media_types)
    end)
    Application.put_env(:liberator, :media_types, %{
      "text/plain" => BrokenMediaType
    })

    defmodule BadMediaTypeCodecResource do
      use Liberator.Resource

      @impl true
      def handle_ok(_), do: %{a: 1, b: 2}
    end

    expected_message = """
    The media type codec module Liberator.ResourceCodecTest.BrokenMediaType did not return a binary.
    Media type codecs must return a binary.

    Liberator.ResourceCodecTest.BrokenMediaType.encode!/1 returned %{a: 1, b: 2}
    """

    conn = conn(:get, "/")

    assert_raise Liberator.MediaTypeCodecInvalidResult, expected_message, fn ->
      BadMediaTypeCodecResource.call(conn, [])
    end
  end

  test "if compression codec does not return a binary, throws an exception with a nice message" do
    defmodule BrokenEncoding do
      def encode!(_), do: %{a: 1, b: 2}
    end

    encodings = Application.fetch_env!(:liberator, :encodings)
    on_exit(fn ->
      Application.put_env(:liberator, :encodings, encodings)
    end)
    Application.put_env(:liberator, :encodings, %{
      "identity" => BrokenEncoding
    })

    defmodule BadCompressionCodecResource do
      use Liberator.Resource

      @impl true
      def handle_ok(_), do: %{a: 1, b: 2}
    end

    expected_message = """
    The compression codec module Liberator.ResourceCodecTest.BrokenEncoding did not return a binary.
    Compression codecs must return a binary.

    Liberator.ResourceCodecTest.BrokenEncoding.encode!/1 returned %{a: 1, b: 2}
    """

    conn = conn(:get, "/")

    assert_raise Liberator.CompressionCodecInvalidResult, expected_message, fn ->
      BadCompressionCodecResource.call(conn, [])
    end
  end
end
