defmodule Liberator.Encoding.Identity do
  @behaviour Liberator.Codec

  @moduledoc """
  An implementation of the `identity` compression used in HTTP.
  That is to say, a no-op function that returns its argument.
  """

  @impl true
  def encode!(body), do: body
end
