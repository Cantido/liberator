<!--
SPDX-FileCopyrightText: 2024 Rosa Richter

SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Liberator

[![Hex.pm](https://img.shields.io/hexpm/v/liberator)](https://hex.pm/packages/liberator/)
[![builds.sr.ht status](https://builds.sr.ht/~cosmicrose/liberator.svg)](https://builds.sr.ht/~cosmicrose/liberator?)
[![liberapay goals](https://img.shields.io/liberapay/goal/rosa.svg?logo=liberapay)](https://liberapay.com/rosa)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code_of_conduct.md)

An Elixir library for building applications with HTTP.

Liberator is a port of the [Liberator](https://clojure-liberator.github.io/liberator/) Clojure library
that allows you to define a controller that adheres to the HTTP spec by providing just a few pieces of information.
It implements a [decision graph] of simple boolean questions that lead your app to the correct HTTP status codes.

While Phoenix and Plug make routing easy, they don't do anything with content negotiation,
or cache management, or existence checks, or anything like that,
beyond calling the right controller function based on the HTTP method.
There are a lot of decisions to make before returning the right HTTP status code,
but Phoenix doesn't give you any additional power to do so.
Liberator does.

## Install

This package is [available in Hex](https://hex.pm/packages/liberator).
Install it by adding `liberator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:liberator, "~> 1.4.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and can be found online at [https://hexdocs.pm/liberator](https://hexdocs.pm/liberator).

## Usage

For a basic `GET` endpoint, you can define an entire module in five lines of code.
Technically you don't even need to implement these two,
since sensible defaults are provided.

```elixir
defmodule MyFirstResource do
  use Liberator.Resource

  def available_media_types(_), do: ["text/plain"]
  def handle_ok(_), do: "Hello world!"
end
```

It doesn't look like much, but behind the scenes,
Liberator navigated a [decision graph] of content negotation, cache management,
and existence checks before returning 200 OK.
Liberator finds the best media type you support,
and automatically encodes your return value.
JSON is supported out of the box, and any additional types
can be provided in a line of the config.

```elixir
# in config.exs
config :liberator, media_types: %{
  "application/json" => Jason,
  "application/xml" => MyXmlCodec
}

# in your main body of code
defmodule MyJsonOrXmlResource do
  use Liberator.Resource

  def available_media_types(_), do: ["application/json", "application/xml"]
  def handle_ok(_), do: %{message: "hi!"}
end
```

A Liberator Resource implements the [Plug](https://github.com/elixir-plug/plug) spec,
so you can forward requests to it in frameworks like Phoenix:

```elixir
scope "/api", MyApp do
  pipe_through [:api]

  forward "/resources", MyFirstResource
end
```

Your results from questions are aggregated into the `:assigns` map on the conn,
so you don't have to access data more than once.

```elixir
defmodule MaybeExistingResource do
  use Liberator.Resource

  def exists?(conn) do
    case MyApp.Repo.get(MyApp.Post, conn.params["id"]) do
      nil -> false
      post -> %{post: post}
    end
  end
  def handle_ok(conn), do: conn.assigns[:post]
end
```

See more in the [Getting Started guide](guides/getting_started.md),
and in the [documentation for `Liberator.Resource`](https://hexdocs.pm/liberator/Liberator.Resource.html).
You can also see an example controller built with Liberator at [the `liberator_example` project](https://github.com/Cantido/liberator_example/).

## Maintainer

This project was developed by [Rosa Richter](https://about.me/rosa.richter).
You can get in touch with her on [Keybase.io](https://keybase.io/cantido).

## Thanks

Thanks to the maintainers of the original Clojure [liberator] project,
[Philipp Meier] and [Malcolm Sparks], for creating such a handy tool.
Their great documentation was an immense help in porting it to Elixir.
And thanks to the maintainers of Erlang's [webmachine](https://github.com/basho/webmachine) for inspiring them!

[Philipp Meier]: https://github.com/ordnungswidrig
[Malcolm Sparks]: https://github.com/malcolmsparks
[liberator]: https://github.com/clojure-liberator/liberator
[webmachine]: https://github.com/basho/webmachine

## Contributing

Questions and pull requests are more than welcome.
I follow Elixir's tenet of bad documentation being a bug,
so if anything is unclear, please [file an issue](https://todo.sr.ht/~cosmicrose/liberator) or ask on the [mailing list]!
Ideally, my answer to your question will be in an update to the docs.

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for all the details you could ever want about helping me with this project.

Note that this project is released with a Contributor [Code of Conduct].
By participating in this project you agree to abide by its terms.

## License

MIT License

Copyright 2024 Rosa Richter

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

[Code of Conduct]: code_of_conduct.md
[decision graph]: guides/default_decision_tree.svg
[mailing list]: https://lists.sr.ht/~cosmicrose/liberator
