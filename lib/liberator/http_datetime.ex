# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Liberator.HTTPDateTime do
  @moduledoc false
  @moduledoc since: "1.2"

  @strftime_format "%a, %d %b %Y %H:%M:%S GMT"

  @doc """
  Checks to see if a string is a valid HTTP date.

  ## Examples

      iex> Liberator.HTTPDateTime.valid?("Wed, 21 Oct 2015 07:28:00 GMT")
      true
      iex> Liberator.HTTPDateTime.valid?("2015-10-21 07:28:00Z")
      false
  """
  @doc since: "1.2"
  def valid?(str) do
    case parse(str) do
      {:ok, _time} -> true
      _ -> false
    end
  end

  @doc """
  Parses an HTTP Date string into an Elixir `DateTime` object.

  ## Examples

      iex> Liberator.HTTPDateTime.parse("Wed, 21 Oct 2015 07:28:00 GMT")
      {:ok, ~U[2015-10-21 07:28:00Z]}
      iex> Liberator.HTTPDateTime.parse("2015-10-21 07:28:00Z")
      {:error,  "Expected `weekday abbreviation` at line 1, column 1."}
  """
  @doc since: "1.2"
  def parse(str) do
    case Timex.parse(str, @strftime_format, :strftime) do
      {:ok, datetime} -> {:ok, DateTime.from_naive!(datetime, "Etc/UTC")}
      err -> err
    end
  end

  @doc """
  Like `parse/1` except will raise an error if the string cannot be parsed.

  ## Examples

      iex> Liberator.HTTPDateTime.parse!("Wed, 21 Oct 2015 07:28:00 GMT")
      ~U[2015-10-21 07:28:00Z]
  """
  @doc since: "1.2"
  def parse!(str) do
    Timex.parse!(str, @strftime_format, :strftime)
    |> DateTime.from_naive!("Etc/UTC")
  end

  @doc """
  Formats a datetime into an HTTP Date string, and raises if there is an error.

  ## Examples

      iex> Liberator.HTTPDateTime.format!(~U[2015-10-21 07:28:00Z])
      "Wed, 21 Oct 2015 07:28:00 GMT"
  """
  def format!(%DateTime{} = datetime) do
    Calendar.strftime(datetime, @strftime_format)
  end
end
