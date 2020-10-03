import Config

config :liberator,
  codecs: %{
    "text/plain" => Liberator.TextPlainCodec,
    "application/json" => Jason
  }
