# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Liberator.MediaType do
  @moduledoc """
  A behaviour module for media type codecs.

  Liberator uses this behaviour to help make sure at compile-time that codecs will be called successfully.
  Include it in your own module for the same peace of mind.
  """

  @doc """
  Encode an Elixir term into an encoded binary, and raise if there's an error.
  """
  @callback encode!(term()) :: binary()
end
