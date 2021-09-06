ARG MIX_ENV=dev

all:
  BUILD +lint
  BUILD +test

get-deps:
  FROM elixir:1.12-alpine
  RUN mix do local.rebar --force, local.hex --force
  COPY mix.exs .
  COPY mix.lock .

  RUN mix deps.get

compile-deps:
  FROM +get-deps
  RUN MIX_ENV=$MIX_ENV mix deps.compile

build:
  FROM +compile-deps

  COPY config ./config
  COPY priv ./priv
  COPY lib ./lib

  RUN MIX_ENV=$MIX_ENV mix compile

lint:
  FROM +build

  RUN MIX_ENV=$MIX_ENV mix credo list

test:
  FROM --build-arg MIX_ENV=test +build

  COPY test ./test

  RUN MIX_ENV=test mix test
