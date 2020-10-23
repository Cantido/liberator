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

  forward "/posts", HelloWeb.PostsResource
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

```sh
$ curl --location --request GET 'http://localhost:4000/posts/'
HTTP/1.1 200 OK
allow: GET, HEAD
cache-control: max-age=0, private, must-revalidate
content-encoding: identity
content-length: 2
content-type: text/plain
date: Thu, 15 Oct 2020 22:54:57 GMT
server: Cowboy
x-request-id: Fj5MYV-9JH1y19wAACQl


OK
```


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


```sh
$ curl --location --request GET 'http://localhost:4000/posts/'
HTTP/1.1 200 OK
allow: GET, HEAD
cache-control: max-age=0, private, must-revalidate
content-encoding: identity
content-length: 27
content-type: text/plain
date: Thu, 15 Oct 2020 22:53:42 GMT
server: Cowboy
x-request-id: Fj5MT91NPreSB7QAABqF


2020-10-15T22:53:30.668000Z
```

That's barely better than regular Phoenix controllers, so let's go further.
Since we're trying to write an API, why don't we grab our Repo and try to get some data out in the world?

```elixir
defmodule HelloWeb.PostsResource do
  use Liberator.Resource

  @impl true
  def handle_ok(conn) do
    id = List.last(conn.path_info)
    post = Hello.Blog.get_post!(id)

    post.title <> "\n\n" <> post.content
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
The `exists?/1` callback expects you to return a boolean, a `Map`, or the `conn`.
If you return a `Map`, Liberator will merge that into `conn.assigns`.

```elixir
defmodule HelloWeb.PostsResource do
  use Liberator.Resource

  @impl true
  def exists?(conn) do
    id = List.last(conn.path_info)
    try do
      Hello.Blog.get_post!(id)
    rescue
      Ecto.NoResultsError -> false
      ArgumentError -> false
    else
      post -> %{post: post}
    end
  end

  @impl true
  def handle_ok(conn) do
    post = conn.assigns[:post]
    post.title <> " " <> post.content
  end
end
```

```sh
$ curl --location --request GET 'http://localhost:4000/posts/1555'
HTTP/1.1 404 Not Found
allow: GET, HEAD
cache-control: max-age=0, private, must-revalidate
content-encoding: identity
content-length: 9
content-type: text/plain
date: Thu, 15 Oct 2020 22:52:25 GMT
server: Cowboy
x-request-id: Fj5MPb9fgMWho78AABkF


Not Found
```

Now we get a nice "Not Found" response!
So, last, we want to be able to POST something.
That introduces us to the concept of actions,
which are just another kind of overridable function.
There are four actions in Liberator:

- `delete!`
- `patch!`
- `post!`
- `put!`

As you could guess, these actions will be called based on the request's HTTP method.
For now, we'll set up `post!`.
Add `c:Liberator.Resource.post!/1` to insert the params.
We also want to make sure that we allow POST requests,
so define `c:Liberator.Resource.allowed_methods/1` too.

We could parse the request body here if we wanted, but Plug provides the `Plug.Parsers` plug,
and it's already set up in this beginner project for accepting JSON.
The params are available in `conn.params`, so we can pass those into our context module directly,
and let the changeset handle validation.

```elixir
defmodule HelloWeb.PostsResource do
  use Liberator.Resource

  @impl true
  def allowed_methods(_), do: ["POST", "GET"]

  @impl true
  def exists?(conn) do
    id = List.last(conn.path_info)
    case Hello.Repo.get(Hello.Blog.Post, id) do
      nil -> false
      post -> %{post: post}
    end
  end

  @impl true
  def post!(conn) do
    {:ok, _post} = Hello.Blog.create_post(conn.params)
  end

  @impl true
  def handle_ok(conn) do
    post = conn.assigns[:post]
    post.title <> " " <> post.content
  end
end
```

That's all!
Let's POST to our new endpoint now.

```sh
$ curl --location --request POST 'http://localhost:4000/posts' \
> --header 'Content-Type: application/json' \
> --data-raw '{
>     "title": "My first post!",
>    "content": "This is so fun!"
> }'
HTTP/1.1 201 Created
allow: POST, GET
cache-control: max-age=0, private, must-revalidate
content-encoding: identity
content-length: 7
content-type: text/plain
date: Thu, 15 Oct 2020 22:42:07 GMT
server: Cowboy
x-request-id: Fj5L-UYbiai2oD4AADaB


Created
```

Finally, point your browser at http://localhost:4000/posts/1.

```sh
curl --location --request GET 'http://localhost:4000/posts/1'
HTTP/1.1 200 OK
allow: POST, GET
cache-control: max-age=0, private, must-revalidate
content-encoding: identity
content-length: 30
content-type: text/plain
date: Thu, 15 Oct 2020 22:47:30 GMT
server: Cowboy
x-request-id: Fj5LreF6rvXe6igAABoD


My first post! This is so fun!
```


You've done it!
You've just built JSON endpoint with a fair amount of built-in smarts.
There's so much more to customize, but now you've got a base to work from.
Check out the documentation for [`Liberator.Resource`](https://hexdocs.pm/liberator/Liberator.Resource.html)
to see all the stuff you can do!
