# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.Conn do
  import Plug.Conn

  @moduledoc """
  Utility functions for dealing with `Plug.Conn` structs.
  """

  @doc """
  Reads the body from the conn, and puts it in the assigns under the key `:raw_body`.

  Accepts the same headers as `Plug.Conn.read_body/2`:

  * `:length` - sets the maximum number of bytes to read from the body for
    each chunk, defaults to `64_000` bytes
  * `:read_length` - sets the amount of bytes to read at one time from the
    underlying socket to fill the chunk, defaults to `64_000` bytes
  * `:read_timeout` - sets the timeout for each socket read, defaults to
    `5_000` milliseconds
  """
  def read_body(%Plug.Conn{} = conn, opts \\ []) do
    {key, body, conn} = Plug.Conn.read_body(conn, opts)

    case key do
      :more -> assign(conn, :raw_body, :too_large)
      :ok -> assign(conn, :raw_body, body)
    end
  end
end
