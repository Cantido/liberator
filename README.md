# Liberator

![Hex.pm](https://img.shields.io/hexpm/v/liberator)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/Cantido/liberator/Elixir%20CI)

An Elixir port of the [Liberator](https://clojure-liberator.github.io/liberator/) Clojure library for building RESTful applications.

You can find documentation at https://hexdocs.pm/liberator/.

Liberator allows you to define a controller that adheres to the HTTP spec by providing just a few pieces of information.
For a basic `GET` endpoint, you can define an entire module in five lines of code:

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

Content negotiation and representation becomes easy.
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
