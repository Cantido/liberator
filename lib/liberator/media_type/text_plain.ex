defmodule Liberator.MediaType.TextPlain do
  @behaviour Liberator.MediaType

  @moduledoc """
  An implementation of a `text/plain` encoder for HTTP.
  """

  @impl true
  def encode!(body) do
    if is_binary(body) and String.printable?(body) do
      body
    else
      inspect(body, pretty: true)
    end
  end
end
