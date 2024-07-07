# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.UnknownStepException do
  @moduledoc """
  Liberator's decision tree evaluator encountered a step that it doesn't know what to do with.
  """

  defexception [:message]

  @impl true
  def exception({next_step, module}) do
    msg = """
      Liberator encountered an unknown step called #{inspect(next_step)}

      In module: #{inspect(module)}

      A couple things could be wrong:

      - If you have overridden part of the decision tree with :decision_tree_overrides,
        make sure that the atoms in the {true, false} tuple values have their own entries in the map.

      - If you have overridden part of the handler tree with :handler_status_overrides,
        or the action followups with :action_followup_overrides,
        make sure that the handler the atoms you passed in are spelled correctly,
        and match what the decision tree is calling.
    """

    %Liberator.UnknownStepException{message: msg}
  end
end

defmodule Liberator.InvalidRetryAfterValueException do
  @moduledoc """
  Liberator was unable to process the given `:retry_after` value into an HTTP date.
  """

  defexception [:message]

  @impl true
  def exception({retry_after, module}) do
    msg =
      "Value for :retry_after was not a valid DateTime, integer, or String, but was #{inspect(retry_after)}. " <>
        "Make sure the too_many_requests?/1 function of #{inspect(module)} is setting that key to one of those types. " <>
        "Remember that you can also just return true or false."

    %Liberator.InvalidRetryAfterValueException{message: msg}
  end
end

defmodule Liberator.InvalidLastModifiedValueException do
  @moduledoc """
  Liberator was unable to process the given `:last_modified` value into an HTTP date.
  """

  defexception [:message]

  @impl true
  def exception({last_modified_result, module}) do
    msg = """
    Value from #{inspect(module)}.last_modified/1 could not be formatted into an HTTP DateTime string.
    Make sure that last_modified/1 is returning an Elixir DateTime object.
    Got: #{inspect(last_modified_result)}.
    """

    %Liberator.InvalidLastModifiedValueException{message: msg}
  end
end

defmodule Liberator.MediaTypeCodecNotFoundException do
  @moduledoc """
  Liberator was unable to find a media type codec for the given encoding.
  """

  defexception [:message]

  @impl true
  def exception(media_type) do
    msg =
      "No codec found for media type #{media_type}. " <>
        "Add a codec module to the :media_types map under the :liberator config in config.exs."

    %Liberator.MediaTypeCodecNotFoundException{message: msg}
  end
end

defmodule Liberator.MediaTypeCodecInvalidResultException do
  @moduledoc """
  A provided media type codec returned an invalid value.

  The `c:Liberator.MediaType.encode!/1` function must return a binary.
  """

  defexception [:message]

  @impl true
  def exception({mediatype_codec, encoded_body}) do
    msg = """
    The media type codec module #{inspect(mediatype_codec)} did not return a binary.
    Media type codecs must return a binary.

    #{inspect(mediatype_codec)}.encode!/1 returned #{inspect(encoded_body)}
    """

    %Liberator.MediaTypeCodecInvalidResultException{message: msg}
  end
end

defmodule Liberator.CompressionCodecNotFoundException do
  @moduledoc """
  Liberator was unable to find a compression codec for the given encoding.
  """

  defexception [:message]

  @impl true
  def exception(encoding) do
    msg =
      "No codec found for encoding #{encoding}. " <>
        "Add a codec module to the :encodings map under the :liberator config in config.exs."

    %Liberator.CompressionCodecNotFoundException{message: msg}
  end
end

defmodule Liberator.CompressionCodecInvalidResultException do
  @moduledoc """
  A provided compression codec returned an invalid value.

  The `c:Liberator.Encoding.encode!/1` function must return a binary.
  """

  defexception [:message]

  @impl true
  def exception({compression_codec, compressed_body}) do
    msg = """
    The compression codec module #{inspect(compression_codec)} did not return a binary.
    Compression codecs must return a binary.

    #{inspect(compression_codec)}.encode!/1 returned #{inspect(compressed_body)}
    """

    %Liberator.CompressionCodecInvalidResultException{message: msg}
  end
end
