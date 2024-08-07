# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.Encoding.Deflate do
  @behaviour Liberator.Encoding

  @moduledoc """
  An implementation of the `deflate` compression used in HTTP.
  """

  @impl true
  def encode!(body) do
    z = :zlib.open()
    :zlib.deflateInit(z)
    b = :zlib.deflate(z, :binary.bin_to_list(body), :finish)
    :zlib.deflateEnd(z)
    IO.iodata_to_binary(b)
  end
end
