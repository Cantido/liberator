defmodule Liberator.Encoding.Deflate do
  def encode!(body) do
    z = :zlib.open()
    :zlib.deflateInit(z)
    b = :zlib.deflate(z, :binary.bin_to_list(body), :finish)
    :zlib.deflateEnd(z)
    IO.iodata_to_binary(b)
  end
end
