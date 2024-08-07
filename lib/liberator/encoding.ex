# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.Encoding do
  @moduledoc """
  A behaviour module for compression codecs.

  Liberator uses this behaviour to help make sure at compile-time that codecs will be called successfully.
  Include it in your own module for the same peace of mind.
  """

  @doc """
  Encode a binary into an encoded form, and raises if there's an error.
  """
  @callback encode!(binary()) :: binary()
end
