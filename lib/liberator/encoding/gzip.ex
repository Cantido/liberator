# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Liberator.Encoding.Gzip do
  @behaviour Liberator.Encoding

  @moduledoc """
  An implementation of the `gzip` compression used in HTTP.
  """

  @impl true
  def encode!(body) do
    :zlib.gzip(:binary.bin_to_list(body))
  end
end
