# Getting Started

Let's get a Liberator endpoint up and running as fast as possible.

First, you'll probably want to fire up a Phoenix application.
Check out [Phoenix's Installation Guide](https://hexdocs.pm/phoenix/installation.html)
and [their Up and Running Guide](https://hexdocs.pm/phoenix/up_and_running.html)
and install it if you don't have it already,
then create a new project with `phx.new`.

Since Liberator was built to help create APIs,
we will disable HTML generation.
We'll keep Ecto, though.

```sh
$ mix phx.new hello --no-html --no-webpack
```

> We'll skip the details of setting up an Ecto repo,
> because it's not necessary to have one running to use Liberator.
> However, your data probably lives in a repo,
> so this example will contain some references to one.

Add `liberator` to your list of dependencies in `mix.exs`

```elixir
def deps do
  [
    {:liberator, "~> 1.3.0"}
  ]
end
```

Then we'll use `mix phx.gen.json` to create a basic schema, route, and context.
It will create a controller as well, but we'll be replacing that with a Liberator Resource.

```sh
$ mix phx.gen.json Blog Post posts title:string content:string
```

Migrate the database as the command feedback requests, if you've got your database handy.
However, don't copy the statement they're asking you to put in `lib/hello_web/router.ex`.
We're going to use our own.
In `lib/hello_web/router.ex`, forward any `/posts` requests to the resource we're about to define.

```elixir
defmodule HelloWeb.Router do
  use HelloWeb, :router

  forward "/posts", HelloWeb.PostResource
end
```

Now we must actually create our first Liberator resource.
Go ahead and delete the file at `lib/controllers/posts_controller.ex` that Phoenix generated for you,
and create a file at `lib/controllers/posts_resource.ex` with the following content.

```elixir
defmodule HelloWeb.PostsResource do
  use Liberator.Resource
end
```

Run the project with `mix phx.server` and check out `http://localhost:4000/posts`.
With Liberator's sensible defaults, it should return a status of 200 and content of `OK`.
Let's spice that up a little more and get some dynamic content in here.

```elixir
defmodule HelloWeb.PostsResource do
  use Liberator.Resource

  @impl true
  def handle_ok(_conn) do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end
end
```

That's barely better than regular Phoenix controllers, so let's go further.
Since we're trying to write an API, why don't we grab our Repo and try to get some data out in the world?

```elixir
defmodule HelloWeb.PostsResource do
  use Liberator.Resource

  @impl true
  def handle_ok(conn) do
    id = List.last(conn.path_info)
    post = Hello.Repo.get!(Hello.Blog.Post, id)

    post.title <> post.content
  end
end
```

Now if you try to hit `http://localhost:4000/posts/5`, we get a Phoenix exception.
Nothing is in the database, of course.
We must check to see if the given ID exists in the database,
and here's where Liberator's features start to show.

Implement the `c:Liberator.Resource.exists?/1` callback in your resource.
Here we can check for the resource.
In fact, let's just grab the entire thing and stick in back in the `conn`.
The `exists?/1` callback expects you to return either a boolean or a `Map`.
If you return a `Map`, Liberator will merge that into `conn.assigns`.

> Note that the `conn` that is passed into each callback is not returned by the callback.
> Therefore you are not able to modify the conn besides adding stuff to `:assigns`.
> It's a different way to work, but the one of the goals of this library is to do all the header-manipulation for you.

```elixir
defmodule HelloWeb.PostsResource do
  use Liberator.Resource

  @impl true
  def exists?(conn) do
    id = List.last(conn.path_info)
    case Hello.Repo.get(Hello.Blog.Post, id) do
      nil -> false
      post -> %{post: post}
    end
  end

  @impl true
  def handle_ok(conn) do
    post = conn.assigns[:post]
    "TITLE: " <> post.title <> "\nCONTENT: " <> post.content
  end
end
```

Now we get a nice "Not Found" response!
