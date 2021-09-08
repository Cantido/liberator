# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Liberator.Encoding.Identity do
  @behaviour Liberator.Encoding

  @moduledoc """
  An implementation of the `identity` compression used in HTTP.
  That is to say, a no-op function that returns its argument.
  """

  @impl true
  def encode!(body), do: body
end
