# Liberator

[![Hex.pm](https://img.shields.io/hexpm/v/liberator)](https://hex.pm/packages/liberator/)
[![Build Status](https://travis-ci.com/Cantido/liberator.svg?branch=master)](https://travis-ci.com/Cantido/liberator)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code_of_conduct.md)
[![Gitter](https://badges.gitter.im/liberator-elixir/community.svg)](https://gitter.im/liberator-elixir/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

An Elixir library for building RESTful applications.

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
    {:liberator, "~> 1.3.0"}
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

See more in the [documentation for `Liberator.Resource`](https://hexdocs.pm/liberator/Liberator.Resource.html).

## Maintainer

This project was developed by [Rosa Richter](https://github.com/Cantido).
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
so if anything is unclear, please [file an issue](https://github.com/Cantido/liberator/issues/new)!
Ideally, my answer to your question will be in an update to the docs.

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for all the details you could ever want about helping me with this project.

Note that this project is released with a Contributor [Code of Conduct].
By participating in this project you agree to abide by its terms.

## License

MIT License

Copyright 2020 Rosa Richter

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[Code of Conduct]: code_of_conduct.md
[decision graph]: https://clojure-liberator.github.io/liberator/tutorial/decision-graph.html
