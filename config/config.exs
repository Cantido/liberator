# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

import Config

config :liberator,
  media_types: %{
    "text/plain" => Liberator.MediaType.TextPlain,
    "application/json" => Jason
  },
  encodings: %{
    "identity" => Liberator.Encoding.Identity,
    "deflate" => Liberator.Encoding.Deflate,
    "gzip" => Liberator.Encoding.Gzip
  }

config :logger, :default_formatter,
  metadata: [:request_id]

