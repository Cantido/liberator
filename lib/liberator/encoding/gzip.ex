defmodule Liberator.Encoding.Gzip do
  @behaviour Liberator.Codec

  @moduledoc """
  An implementation of the `gzip` compression used in HTTP.
  """

  @impl true
  def encode!(body) do
    :zlib.gzip(:binary.bin_to_list(body))
  end
end
