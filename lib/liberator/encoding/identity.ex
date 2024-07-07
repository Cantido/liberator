# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.Encoding.Identity do
  @behaviour Liberator.Encoding

  @moduledoc """
  An implementation of the `identity` compression used in HTTP.
  That is to say, a no-op function that returns its argument.
  """

  @impl true
  def encode!(body), do: body
end
