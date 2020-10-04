defmodule Liberator.Codec do
  @moduledoc """
  A behaviour module for media type and compression codecs.

  Liberator uses this behaviour to help make sure at compile-time that codecs will be called successfully.
  Include it in your own module for the same peace of mind.
  """

  @doc """
  Encode a binary into an encoded form, and raises if there's an error.
  """
  @callback encode!(binary()) :: binary()
end
