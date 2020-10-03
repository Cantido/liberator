defmodule Liberator.Encoding.Gzip do
  def encode!(body) do
    :zlib.gzip(:binary.bin_to_list(body))
  end
end
