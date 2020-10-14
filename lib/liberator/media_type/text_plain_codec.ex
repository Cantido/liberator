defmodule Liberator.MediaType.TextPlainCodec do
  @behaviour Liberator.MediaType

  @moduledoc """
  An implementation of a `text/plain` encoder for HTTP.
  That is to say, a no-op that returns its argument.
  """

  @impl true
  def encode!(str), do: str
end
