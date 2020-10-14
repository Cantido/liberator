defmodule Liberator.MediaType.TextPlainCodec do
  @behaviour Liberator.MediaType

  @moduledoc """
  An implementation of a `text/plain` encoder for HTTP.
  """

  @impl true
  def encode!(body) do
    if String.printable?(body) do
      body
    else
      inspect(body, pretty: true)
  end
end
