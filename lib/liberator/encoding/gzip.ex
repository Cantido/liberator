# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

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
