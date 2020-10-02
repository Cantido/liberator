# Liberator

![Hex.pm](https://img.shields.io/hexpm/v/liberator)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/Cantido/liberator/Elixir%20CI)

An Elixir port of the [Liberator](https://clojure-liberator.github.io/liberator/) Clojure library for building RESTful applications.

You can find documentation at https://hexdocs.pm/liberator/.

Liberator allows you to define a controller that adheres to the HTTP spec by providing just a few pieces of information.
For a basic `GET` endpoint. you can define the entire module in five lines of code:

```elixir
defmodule MyFirstResource do
  use Liberator.Resource

  def available_media_types(_), do: ["text/plain"]
  def handle_ok(_), do: "Hello world!"
end
```

A Liberator Resource implements the [Plug](https://github.com/elixir-plug/plug) spec,
so you can forward requests to it in frameworks like Phoenix:

```elixir
scope "/", MyApp do
  pipe_through [:browser]

  forward "/api/resource", MyFirstResource
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `liberator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:liberator, "~> 1.0.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/liberator](https://hexdocs.pm/liberator).
