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
