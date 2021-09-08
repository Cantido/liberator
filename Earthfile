# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

ARG MIX_ENV=dev

all:
  BUILD +lint
  BUILD +lint-copyright
  BUILD +test

get-deps:
  FROM elixir:1.12-alpine
  RUN mix do local.rebar --force, local.hex --force
  COPY mix.exs .
  COPY mix.lock .

  RUN mix deps.get

  SAVE ARTIFACT deps AS LOCAL ./deps

compile-deps:
  FROM +get-deps
  RUN MIX_ENV=$MIX_ENV mix deps.compile

  SAVE ARTIFACT _build/$MIX_ENV AS LOCAL ./_build/$MIX_ENV

build:
  FROM +compile-deps

  COPY config ./config
  COPY priv ./priv
  COPY lib ./lib

  RUN MIX_ENV=$MIX_ENV mix compile

  SAVE ARTIFACT _build/$MIX_ENV AS LOCAL ./_build/$MIX_ENV

lint:
  FROM +build

  RUN MIX_ENV=$MIX_ENV mix credo list

lint-copyright:
  FROM fsfe/reuse

  COPY . .

  RUN reuse lint

sast:
  FROM +build

  RUN MIX_ENV=$MIX_ENV mix sobelow --skip

test:
  FROM --build-arg MIX_ENV=test +build

  COPY test ./test

  RUN MIX_ENV=test mix test
