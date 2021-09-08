# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Liberator.Resource do
  @moduledoc """
  A controller module that understands and respects the HTTP spec.

  This module implements a `Plug` handler that allows an endpoint to comply to the HTTP specification,
  and to do so by just answering a few questions.

  Define a simple resource like this:

      defmodule MyFirstResource do
        use Liberator.Resource

        def handle_ok(_), do: "Hello world!"
      end

  To add this plug to a Phoenix application, use the `Phoenix.Router.forward/4` keyword in your router:

      scope "/", MyApp do
        pipe_through [:browser]

        forward "/api/resource", MyFirstResource
      end

  If you're using another Plug-based framework, use `Plug.forward/4` once you've matched on the path:

      defmodule Router do
       def init(opts), do: opts

       def call(conn, opts) do
         case conn do
           %{host: "localhost", path_info: ["resources" | rest]} ->
             Plug.forward(conn, rest, MyFirstResource, opts)

           _ ->
             MainRouter.call(conn, opts)
         end
       end
      end

  There are lots of decisions to be made during content negotiation,
  and Liberator lets gives you access to every single one,
  but it's also built with sensible defaults that let you quickly build up a controller.

  ## Content Negotiation

  These functions return lists of available values during content negotiation.
  If the client has an accept header that does not match a value from these lists,
  the plug will return a `406 Not Acceptable` response, and call `c:handle_not_acceptable/1`.

  | Function                    | Default                             |
  |-----------------------------|-------------------------------------|
  | `c:allowed_methods/1`       | `["GET", "HEAD"]`                   |
  | `c:known_methods/1`         | `["GET", "HEAD", "OPTIONS", "PUT", "POST", "DELETE", "PATCH", "TRACE"]` |
  | `c:available_media_types/1` | `["text/plain", "application/json"]`|
  | `c:available_languages/1`   | `["*"]`                             |
  | `c:available_charsets/1`    | `["UTF-8"]`                         |
  | `c:available_encodings/1`   | `["gzip", "deflate","identity"]`    |
  | `c:maximum_entity_length/1` | `64_000`                            |

  Liberator supports a few basic defaults to help you get up and running.
  It uses `Jason` for `application/json` media responses,
  but you can override that, along with the compression handlers.
  Just include your custom codecs in `config.exs` under the `:liberator` key.
  Media type codecs go under `:media_types`, and compression goes under `:encodings`.
  Here's the default as an example:

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

  As long as your codec module implements an `encode!/1` function that accepts and returns a response body,
  Liberator will call it at the right place in the pipeline.
  Implement the `Liberator.MediaType` or `Liberator.Encoding` behaviour for some compile-time assurance that you've implemented the correct function.

      defmodule MyXmlCodec do
        @behaviour Liberator.MediaType

        @impl true
        def encode!(body) do
          # your cool new functionality here
        end
      end

  ## Preconditions

  These functions decide the state of preconditon decisions for the request.
  Depending on the specific method and request headers,
  the plug may return a `412 Precondition Failed` response, a `304 Not Modified` response,
  or may allow another kind of request to continue.

  | Function                    | Default              |
  |-----------------------------|----------------------|
  | `c:last_modified/1`         | `DateTime.utc_now()` |
  | `c:etag/1`                  | `nil`                |

  ## Actions

  Actions make the necessary changes to the requested entity.
  You can return either a `Plug.Conn` struct, or a map, from these functions.
  However, unlike the decision functions, a nil or false return value does nothing different.

  | Function          | Description |
  |-------------------|-------------|
  | `c:initialize/1` | Performs any custom initialization you need before the decision tree starts |
  | `c:delete!/1`    | Called for `DELETE` requests |
  | `c:patch!/1`     | Called for `PATCH` requests  |
  | `c:post!/1`      | Called for `POST` requests   |
  | `c:put!/1`       | Called for `PUT` requests    |

  ## Handlers

  Handlers are called at the very end of the decision tree, and allow you
  to return content for rendering to the client.

  | Function                                    | Status|
  |---------------------------------------------|-------|
  | `c:handle_ok/1`                             | 200 |
  | `c:handle_options/1`                        | 200 |
  | `c:handle_created/1`                        | 201 |
  | `c:handle_accepted/1`                       | 202 |
  | `c:handle_no_content/1`                     | 204 |
  | `c:handle_multiple_representations/1`       | 300 |
  | `c:handle_moved_permanently/1`              | 301 |
  | `c:handle_see_other/1`                      | 303 |
  | `c:handle_not_modified/1`                   | 304 |
  | `c:handle_moved_temporarily/1`              | 307 |
  | `c:handle_malformed/1`                      | 400 |
  | `c:handle_unauthorized/1`                   | 401 |
  | `c:handle_forbidden/1`                      | 403 |
  | `c:handle_not_found/1`                      | 404 |
  | `c:handle_method_not_allowed/1`             | 405 |
  | `c:handle_not_acceptable/1`                 | 406 |
  | `c:handle_conflict/1`                       | 409 |
  | `c:handle_gone/1`                           | 410 |
  | `c:handle_precondition_failed/1`            | 412 |
  | `c:handle_request_entity_too_large/1`       | 413 |
  | `c:handle_uri_too_long/1`                   | 414 |
  | `c:handle_unsupported_media_type/1`         | 415 |
  | `c:handle_unprocessable_entity/1`           | 422 |
  | `c:handle_too_many_requests/1`              | 429 |
  | `c:handle_unavailable_for_legal_reasons/1`  | 451 |
  | `c:handle_unknown_method/1`                 | 501 |
  | `c:handle_not_implemented/1`                | 501 |
  | `c:handle_service_unavailable/1`            | 503 |

  ## Decisions

  Liberator supports a whole lot of decisions points.
  Some of them are needed for next to every resource definition.
  Others are seldom used or there is no other sensible implementation.

  Decision callbacks must return a truthy value, which they can optionally wrap in an `{:ok, result}` tuple.
  Returning `{:error, result}` will always invoke the `handle_error`; see below.

  If the result of the decision is a map, Liberator will merge that map with the `conn`'s `:assigns` map.
  Use this feature to cache data and do work when it makes sense.
  For example, the `exists?/1` callback is a great place to fetch your resource,
  and you can return it as a map for your later functions to act upon.
  That would look something like this:

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

  Here are all the decision functions you can override:

  | Function                    | Description                                                                         | Default  |
  |---                          |---                                                                                  |---       |
  | `c:allowed?/1`              | Is the user allowed to make this request?                                           | true     |
  | `c:authorized?/1`           | Is necessary authentication information present?                                    | true     |
  | `c:charset_available?/1`    | Are any of the requested charsets available? Should assign the `:charset` variable. | Uses values at `c:available_charsets/1` |
  | `c:can_post_to_gone?/1`     | Should we process a `POST` to a resource that previously existed?                   | false |
  | `c:can_post_to_missing?/1`  | Should we process a `POST` to a resource that does not exist?                       | true |
  | `c:can_put_to_missing?/1`   | Should we process a `PUT` to a resource that does not exist?                        | true |
  | `c:conflict?/1`             | Does the `PUT` or `POST` request result in a conflict?                              | false |
  | `c:delete_enacted?/1`       | Was the delete request finally processed?                                           | true |
  | `c:encoding_available?/1`   | Is the requested encoding available? Should assign the `:encoding` variable.        | Uses values at `c:available_encodings/1` |
  | `c:etag_matches_for_if_match?/1` | Does the etag of the current resource match the `If-Match` header?             | Uses value generated by `c:etag/1` |
  | `c:etag_matches_for_if_none?/1` | Does the etag of the current resource match the `If-None-Match` header?         | Uses value generated by `c:etag/1` |
  | `c:existed?/1`              | Did the resource exist before?                                                      | false |
  | `c:exists?/1`               | Does the resource exist?                                                            | true |
  | `c:known_content_type?/1`   | Is the `Content-Type` of the body known?                                            | true |
  | `c:known_method?/1`         | Is the request method known?                                                        | Uses values at `c:known_methods/1` |
  | `c:language_available?/1`   | Is the requested language available? Should assign the `:language` variable.        | Uses values at `c:available_languages/1` |
  | `c:media_type_available?/1` | Is the requested media type available? Should assign the `:media_type` variale.     | Uses values at `c:available_media_types/1` |
  | `c:method_allowed?/1`       | Is the request method allowed for this resource?                                    | Uses values at `c:allowed_methods/1` |
  | `c:modified_since?/1`       | Was the resource modified since the date given in the `If-Modified-Since` header?   | Uses value generated by `c:last_modified/1` |
  | `c:moved_permanently?/1`    | Was the resource moved permanently?                                                 | false |
  | `c:moved_temporarily?/1`    | Was the resource moved temporarily?                                                 | false |
  | `c:multiple_representations?/1` | Are there multiple representations for this resource?                           | false |
  | `c:new?/1`                  | Was the resource created by this request?                                           | true |
  | `c:payment_required?/1`     | Is payment required before this request can be processed?                           | false |
  | `c:post_enacted?/1`         | Was the `POST` request finally processed?                                           | true |
  | `c:put_enacted?/1`          | Was the `PUT` request finally processed?                                            | true |
  | `c:patch_enacted?/1`        | Was the `PATCH` request finally processed?                                          | true |
  | `c:post_redirect?/1`        | Should the response redirect after a `POST`?                                        | false |
  | `c:put_to_different_url?/1` | Should the `PUT` request be made to a different URL?                                | false |
  | `c:processable?/1`          | Is the request body processable?                                                    | true |
  | `c:too_many_requests?/1`    | Has the client or user issued too many requests in a period of time?                | false |
  | `c:service_available?/1`    | Is the service available?                                                           | true |
  | `c:unavailable_for_legal_reasons?/1` | Is the resource not available, for legal reasons?                          | false |
  | `c:uri_too_long?/1`         | Is the request URI too long?                                                        | false |
  | `c:valid_content_header?/1` | Is the `Content-Type` of the body valid?                                            | true |
  | `c:valid_entity_length?/1`  | Is the length of the body valid?                                                    | Uses value at `c:maximum_entity_length/1` |
  | `c:well_formed?/1`            | Is the request parseable?                                                         | true |

  ## Handling Errors

  There is a special handler, named `c:handle_error/3`, that is called when any decision, action, or handler function raises an error or returns `{:error, result}`.
  It functions much like an [`action_fallback`](https://hexdocs.pm/phoenix/controllers.html#action-fallback) module does in Phoenix.

  The `handle_error` handler is called with the `conn`, the error that was raised, and the name of the decision, action, or handler that failed.
  Liberator expects this handler to call `Plug.Conn.send_resp/1` or `Plug.Conn.send_resp/3`, unlike other handlers.
  This allows you to set the status and body yourself, or even use a Phoenix fallback controller.

  The default implementation of `handle_error` works something like this:

      @impl true
      def handle_error(conn, _error, _failed_step) do
        send_resp(conn, 500, "Internal Server Error")
      end

  ## Debugging

  For every request, Liberator builds a list of the decisions called and their answers.
  You can access this list with the `:trace` option of your `use` statement.

  Set it to `:log` for a log message of the full trace.

      defmodule MyFirstResource do
        use Liberator.Resource, trace: :log

        def handle_ok(_), do: "Hello world!"
      end

  You'll get a log message like this:

  ```comment
  14:57:04.861 [debug] Liberator trace for request "my-very-specific-request-id" to /:

      1. initialize: nil (took 1 µs)
      2. service_available?: true (took 1 µs)
      3. known_method?: true (took 1 µs)
      4. uri_too_long?: false (took 1 µs)
      5. method_allowed?: true (took 1 µs)
      6. well_formed?: true (took 1 µs)
      7. authorized?: true (took 1 µs)
      8. allowed?: true (took 1 µs)
      9. too_many_requests?: false (took 1 µs)
      10. payment_required?: false (took 1 µs)
      11. valid_content_header?: true (took 1 µs)
      12. known_content_type?: true (took 1 µs)
      13. valid_entity_length?: true (took 1 µs)
      14. is_options?: false (took 1 µs)
      15. accept_exists?: false (took 1 µs)
      16. accept_language_exists?: false (took 1 µs)
      17. accept_charset_exists?: false (took 1 µs)
      18. accept_encoding_exists?: false (took 1 µs)
      19. processable?: true (took 1 µs)
      20. unavailable_for_legal_reasons?: false (took 1 µs)
      21. exists?: true (took 1 µs)
      22. if_match_exists?: false (took 1 µs)
      23. if_unmodified_since_exists?: false (took 1 µs)
      24. if_none_match_exists?: false (took 1 µs)
      25. if_modified_since_exists?: false (took 1 µs)
      26. method_delete?: false (took 1 µs)
      27. method_patch?: false (took 1 µs)
      28. post_to_existing?: false (took 1 µs)
      29. put_to_existing?: false (took 1 µs)
      30. multiple_representations?: false (took 1 µs)
      31. handle_ok: nil (took 3 µs)
  ```

  Liberator will include the request ID set by the `Plug.RequestId` plug,
  if you have it as part of your pipeline.

  Set the `:trace` option to `:headers` so you can get the trace as HTTP headers.

      defmodule MyFirstResource do
        use Liberator.Resource, trace: :headers

        def handle_ok(_), do: "Hello world!"
      end

  This will add a header called `x-liberator-trace` that will show you the entire set of decisions, in the order they were made.

  Lastly, Liberator is instrumented with the [Telemetry](https://github.com/beam-telemetry/telemetry) library,
  and emits events upon the completion of every request.
  A Resource will emit the following events:

  - `[:liberator, :request, :start]`
  - `[:liberator, :request, :stop]`
  - `[:liberator, :request, :exception]`

  All Telemetry events will contain the request ID and request path as metadata.
  The measurements for `:start` will contain a key called `system_time` which is derived by calling `:erlang.system_time()`
  The measurements for `:stop` and `:exception` will both contain a key called `:duration`, which is the duration of the request in native time units.
  The metadata for the `:stop` event will also contain the execution trace, which is a list of maps with the following keys:

  - `:step`: the name of the function that was executed, or the atoms `:start` or `:stop`
  - `:result`: the value the function returned
  - `:timestamp`: the time the function was called, as an Elixir date struct
  - `:duration`: how long the call took, in native time units

  ## Internationalization and Localization (i18n and l10n)

  During content negotiation (specifically, in the call to `c:language_available?/1`)
  the `accept-language` header is inspected, and the `:language` key is added to `conn.assigns`.
  This callback also sets the `Gettext` locale for the current process to the value it finds, using `Gettext.put_locale/1`.
  So, in your handler functions, all you need to do is make your usual `gettext` calls.
  Everything else is handled for you.

      defmodule MyInternationalizedResource do
        use Liberator.Resource

        def available_languages(_): ["en", "es", "de", "fr"]
        def handle_ok(_), do: gettext("Hello world!")
      end

  All of the default handler messages are internationalized, but we need help with translations!
  If you can help with this, please submit a pull request on [Liberator's GitHub page](https://github.com/Cantido/liberator)!

  ## Advanced Overrides

  Liberator tries to give you access to as much of the program as possible.
  Lots of the guts are open for you to play around in.
  You probably won't ever need to mess with this stuff,
  but it's there if you need it.

  ### Overriding Decisions

  These decision points are used internally by Liberator and provide reasonable defaults.
  Overriding is possible, but not useful in general.

  | Function                                 | Description                                                                    |
  |---                                       |---                                                                             |
  | `c:accept_charset_exists?/1`             | Checks if header `Accept-Charset` exists.                                      |
  | `c:accept_encoding_exists?/1`            | Checks if header `Accept-Encoding` exists.                                     |
  | `c:accept_exists?/1`                     | Checks if header `Accept` exists.                                              |
  | `c:accept_language_exists?/1`            | Checks if header `Accept-Language` exists.                                     |
  | `c:body_exists?/1`                       | Checks if the request has a body.                                              |
  | `c:if_match_exists?/1`                   | Checks if header `If-Match` exists.                                            |
  | `c:if_match_star?/1`                     | Checks if header `If-Match` is `*`.                                            |
  | `c:if_match_star_exists_for_missing?/1`  | Checks if header `If-Match` exists for a resource that does not exist.         |
  | `c:if_modified_since_exists?/1`          | Checks if header `If-Modified-Since` exists.                                   |
  | `c:if_modified_since_valid_date?/1`      | Checks if header `If-Modified-Since` is a valid HTTP date.                     |
  | `c:if_none_match?/1`                     | Checks if the request method to handle failed `If-None-Match`                  |
  | `c:if_none_match_exists?/1`              | Checks if header `If-None-Match` exists.                                       |
  | `c:if_none_match_star?/1`                | Checks if header `If-None-Match` is `*`.                                       |
  | `c:if_unmodified_since_exists?/1`        | Checks if header `If-Unmodified-Since` exists.                                 |
  | `c:if_unmodified_since_valid_date?/1`    | Checks if header `If-Unmodified-Since` is a valid HTTP date.                   |
  | `c:is_options?/1`                        | Checks if the request method is `OPTIONS`                                      |
  | `c:method_delete?/1`                     | Checks if the request method is `DELETE`                                       |
  | `c:method_put?/1`                        | Checks if the request method is `PUT`                                          |
  | `c:method_patch?/1`                      | Checks if the request method is `PATCH`                                        |
  | `c:post_to_gone?/1`                      | Checks if the request method is `POST` for resources that do not exist anymore.|
  | `c:post_to_existing?/1`                  | Checks if the request method is `POST` for resources that do exist.            |
  | `c:post_to_missing?/1`                   | Checks if the request method is `POST` for resources that do not exist.        |
  | `c:put_to_existing?/1`                   | Checks if the request method is `PUT` for a resource that exists.              |


  ### Adding Decisions

  Since version 1.3, you can even override the decision, handler, and action trees.
  To override the decision tree, add an option named `:decision_tree_overrides` into your `use` statement.
  The decision tree is a map of `atom -> {atom, atom}`,
  where all three atoms should be function names in the module that called `use`.
  The first element of the tuple is the next function to call if the key function returns `true`,
  and the second element of the tuple is the function to call if the function returns `false`.
  Your argument to `:decision_tree_overrides` will be merged into the default decision tree.
  For example, here's me overriding the first chunk of the decision tree so that the decision `c:uri_too_long?/1` is completely skipped.
  That decisions happens right after `c:known_method?/1`, so just update that key to call the next decision instead, which is `c:method_allowed?/1`

      defmodule LongUrisResource do
        use Liberator.Resource,
          decision_tree_overrides:  %{
            # instead of known_method?: {:uri_too_long?, :handle_unknown_method}
            known_method?: {:method_allowed?, :handle_unknown_method}
          }
      end

  Every function in the decision matrix needs an entry.
  If you're adding a new decision function of your own,
  that new decision needs to be in both a result tuple and a key.
  Otherwise, Liberator will throw an exception.
  Also note that Liberator cannot detect a cycle in your callbacks,
  so be careful!

  ### Adding Handlers

  To override the handler status, or add your own,
  add an option named `:handler_status_overrides` to your `use` statement,
  with a map of `atom -> integer`.
  The integers are the status codes that Liberator will set before calling the actual handler function.

  If you are adding a new status code to Liberator,
  you'll also need to set `:decision_tree_overrides` in order to actually call this new handler,
  as well as a functions of those names defined in the module that called `use`.
  Here's an example of adding a handler for a new status code:

      defmodule ResourceLikesToParty do
        use Liberator.Resource,
          decision_tree_overrides:  %{
            allowed?: {:likes_to_party?, :handle_forbidden}
            likes_to_party?: {:handle_likes_to_party, :too_many_requests?}
          },
          handler_status_overrides: %{
            handle_likes_to_party: 420
          }

        def likes_to_party?(_conn), do: Enum.random([true, false])
        def handle_likes_to_party(_conn), do: "Hey come party with me sometime."
      end

  In this example, the `likes_to_party?/1` callback is added,
  and if that function returns `false`, it will continue on with the pipeline,
  but if it returns `true`, then it will call the new `handle_likes_to_party/1` callback,
  and set the status code to 420.

  ### Adding Actions

  Finally, you can override actions as well.
  The option is called `:action_followup_overrides`,
  and is a map of `atom -> atom`,
  where both atoms are functions defined in the module that called `use`.
  The first atom is the name of the handler function, like `c:post!/1` or `c:delete!/1`.
  The second atom is the function that will be called immediately after the action.

  Say you're implementing a [WebDAV](https://en.wikipedia.org/wiki/WebDAV) server using Liberator,
  and you want to add your own `COPY` decision, action, and handler.
  By overriding some internals, this is how you'd do it,
  and still have the power of the decision tree on your side!

      defmodule WebDavResource do
        use Liberator.Resource,
          decision_tree_overrides:  %{
            method_delete?: {:delete!, :method_copy?}
            method_copy?: {:lock_token_valid?, :method_patch?}
            lock_token_valid?: {:copy!, :handle_locked}
          },
          handler_status_overrides: %{
            handle_locked: 423
          },
          action_followup_overrides: %{
            copy!: :respond_with_entity?
          }
        }

        @impl true
        def available_media_types(_), do: ["application/xml"]

        @impl true
        def allowed_methods(_), do: ["COPY"]

        @impl true
        def known_methods(_), do: ["GET", "HEAD", "OPTIONS", "PUT", "POST", "DELETE", "PATCH", "TRACE", "COPY"]

        def lock_token_valid?(conn), do: MyWebDavBackend.lock_token_valid?(conn)
        def copy!(conn), do: MyWebDavBackend.copy(conn)
        def handle_locked(_conn), do: "Resource Locked"
      end
  """
  import Plug.Conn

  @doc """
  Returns a list of HTTP methods that this module serves.

  The methods returned by this function should be upper-case strings, like `"GET"`, `"POST"`, etc.
  """
  @doc since: "1.0"
  @callback allowed_methods(Plug.Conn.t()) :: list()

  @doc """
  Returns a list of HTTP methods that exist.

  Note that this is to filter bad HTTP requests, not to filter requests that your endpoint does not serve.
  You probably want to implement `c:allowed_methods/1` instead.

  The methods returned by this function should be upper-case strings, like `"GET"`, `"POST"`, etc.
  """
  @doc since: "1.0"
  @callback known_methods(Plug.Conn.t()) :: list()

  @doc """
  Returns a list of content types that this module serves.

  The types returned by this function should be valid MIME types, like `text/plain`, `application/json`, etc.
  """
  @doc since: "1.0"
  @callback available_media_types(Plug.Conn.t()) :: list()

  @doc """
  Returns a list of available languages.
  """
  @doc since: "1.0"
  @callback available_languages(Plug.Conn.t()) :: list()

  @doc """
  Returns a list of available response content encodings (AKA compressions).

  By default, only `identity` (no compression) is supported.
  """
  @doc since: "1.0"
  @callback available_encodings(Plug.Conn.t()) :: list()

  @doc """
  Returns a list of available content charsets.

  By default, only `UTF-8` is supported.
  """
  @doc since: "1.0"
  @callback available_charsets(Plug.Conn.t()) :: list()

  @doc """
  Configures the maximum length that a request body can be.
  """
  @callback maximum_entity_length(Plug.Conn.t()) :: non_neg_integer()

  @doc """
  Returns the last modified date of your resource.

  This value will be used to respond to caching headers like `If-Modified-Since`.
  """
  @doc since: "1.0"
  @callback last_modified(Plug.Conn.t()) :: DateTime.t()

  @doc """
  Returns the etag for the current entity.

  This value will be used to respond to caching headers like `If-None-Match`.
  """
  @doc since: "1.0"
  @callback etag(Plug.Conn.t()) :: String.t()

  @doc """
  Check if your service is available.

  This is the first function called in the entire pipeline,
  and lets you check to make sure everything works before going deeper.
  If this function returns `false`, then the plug will return a 503 Service Not Available response.

  If this function returns a map containing a value called `:retry_after`,
  Liberator will put this value into a `retry-after` header,
  Some crawlers and spiders honor this value,
  so they will not bother you while you're down,
  and will continue to index your site afterward.
  See [MDN's docs on the `retry-after` header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After)
  for more information.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback service_available?(Plug.Conn.t()) :: true | false

  @doc """
  Check of the HTTP method in the request is one we know about.

  This is different from `c:allowed_methods/1` in that this function
  checks to see if the given HTTP method is an HTTP method at all.
  You probably want to override `c:allowed_methods/1` and not this one,
  unless you're extending HTTP with more verbs.

  If this function returns `false`, then the plug will return a 501 Unknown Method response.

  By default, allows the methods returned by `c:known_methods/1`.
  """
  @doc since: "1.0"
  @callback known_method?(Plug.Conn.t()) :: true | false

  @doc """
  Checks the length of the URI.

  If this function returns true, then the plug will return a 414 URI Too Long response.

  By default, always returns `false`.
  """
  @doc since: "1.0"
  @callback uri_too_long?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the server supports the request's HTTP method.

  Override `c:allowed_methods/1` instead of this function to let this plug perform the check for you.

  By default, allows the methods returned by `c:allowed_methods/1`.
  """
  @doc since: "1.0"
  @callback method_allowed?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request has a body.

  Used internally; it is not advised to override this function.
  """
  @callback body_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check the request for general adherence to some form.

  If this function returns false, then the plug will return a 400 Malformed response.

  This is a good place to parse the request body.
  If, for example, the body is not valid JSON, this is the function that should return false.
  If you're checking the body of a request against some schema,
  like checking if your changeset is valid,
  you should override `c:processable?/1` instead.

  By default, always returns `true`.
  """
  @doc since: "1.4"
  @callback well_formed?(Plug.Conn.t()) :: true | false

  @doc """
  Check the request for general adherence to some form.

  If this function returns true, then the plug will return a 400 Malformed response.

  If you're checking the body of a request against some schema,
  you should override `c:processable?/1` instead.

  By default, always returns `false`.
  """
  @doc since: "1.0"
  @doc deprecated: "Use Liberator.Resource.well_formed?/1 instead"
  @callback malformed?(Plug.Conn.t()) :: true | false

  @doc """
  Check for presence ofauthentication information in the request.

  Note the difference between `c:authorized?/1` and `c:allowed?/1`.
  This function should just check for the presence of authentication information,
  not the content of it.

  If you implement this function to return `false`, your response in `handle_unauthorized`
  must include a `WWW-Authenticate` header field containing a challenge applicable to the requested resource.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback authorized?(Plug.Conn.t()) :: true | false

  @doc """
  Check the authentication information in the request to see if it has the necessary permissions.

  Note the difference between `c:authorized?/1` and `c:allowed?/1`.
  This function checks if the given request is allowed to perform an action,
  but isn't responsible for checking the presence of authentication information in the first place.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback allowed?(Plug.Conn.t()) :: true | false

  @doc """
  Check to see if payment is required for this resource.

  If this function returns true, then the plug will return a 402 Payment Required response.
  Please note that the 402 status code is experimental, and is "reserved for future use."

  By default, always returns `false`.
  """
  @doc since: "1.2"
  @callback payment_required?(Plug.Conn.t()) :: true | false

  @doc """
  Check to see if the client has performed too many requests.
  Used as part of a rate limiting scheme.

  If you return a map containing a `:retry_after` key,
  then the response's `retry-after` header will be automatically set.
  The value of this key can be either an Elixir `DateTime` object,
  a `String` HTTP date, or an integer of seconds.
  All of these values tell the client when they can attempt their request again.
  Note that if you provide a `String` for this value,
  it should be formatted as an HTTP date.

  If you do return map with the key `:retry_after` set,
  and its value is not a `DateTime`, integer, or valid `String`,
  then Liberator will raise an exception.

  By default, always returns `false`.
  """
  @doc since: "1.2"
  @callback too_many_requests?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the Content-Type of the body is valid.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback valid_content_header?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the Content-Type of the body is known.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback known_content_type?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the length of the body is valid.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback valid_entity_length?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is Options.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback is_options?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `Accept` header exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback accept_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request media type is available.

  By default, uses the values returned by `c:available_media_types/1`.
  """
  @doc since: "1.0"
  @callback media_type_available?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `Accept-Language` header exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback accept_language_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the requested language is available.

  By default, uses the values returned by `c:available_languages/1`,
  and returns a map with the key `:language` set to the negotiated language,
  which will be merged into `conn.assigns`.
  """
  @doc since: "1.0"
  @callback language_available?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `Accept-Charset` header exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback accept_charset_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check of the requested charset is available.

  By default, uses the values returned by `c:available_charsets/1`,
  and returns a map with the key `:charset` set to the negotiated charset,
  which will be merged into `conn.assigns`.
  """
  @doc since: "1.0"
  @callback charset_available?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `Accept-Encoding` header exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback accept_encoding_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check of the requested encoding is available.

  By default, uses the values returned by `c:available_encodings/1`,
  and returns a map with the key `:encoding` set to the negotiated encoding,
  which will be merged into `conn.assigns`.
  """
  @doc since: "1.0"
  @callback encoding_available?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the body of the request can be processed.

  This is a good place to parse a JSON body if that's what you're doing.
  Returning `false` here would cause the plug to return a 422 Unprocessable response.
  """
  @doc since: "1.0"
  @callback processable?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the requested entity exists.

  This is a great place to actually fetch the requested resource,
  then return it as a map so it can be merged into the `:assigns` map of the request.

  Returning `false` here will cause the plug to return a 404 Not Found response.
  """
  @doc since: "1.0"
  @callback exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is `PUT`.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback method_put?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the resource ever existed.

  Answering `true` here will lead you down the path that leads to
  responses like "Moved Permanently" and "Gone", among othes.
  """
  @doc since: "1.0"
  @callback existed?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is `POST` to a resource that doesn't exist.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback post_to_missing?(Plug.Conn.t()) :: true | false

  @doc """
  Check if we can process a post to a resource that does not exist,
  or if we should send a 404 Not Found response.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback can_post_to_missing?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the resource was moved permanently.

  By default, always returns `false`.
  """
  @doc since: "1.0"
  @callback moved_permanently?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the resource was moved temporarily.

  By default, always returns `false`.
  """
  @doc since: "1.0"
  @callback moved_temporarily?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the resource is no longer available, for legal reasons.

  If this function returns `true`,
  then the plug will return a 451 Unavailable for Legal Reasons response.

  By default, always returns `false`.
  """
  @doc since: "1.2"
  @callback unavailable_for_legal_reasons?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is `POST` for resources that do not exist anymore.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback post_to_gone?(Plug.Conn.t()) :: true | false

  @doc """
  Decide if we can process a `POST` to a resource that existed before, or return a 410 Gone response.

  By default, always returns `false`.
  """
  @doc since: "1.0"
  @callback can_post_to_gone?(Plug.Conn.t()) :: true | false

  @doc """
  Decide if a `PUT` request should be made to a different URL.

  By default, always returns `false`.
  """
  @doc since: "1.0"
  @callback put_to_different_url?(Plug.Conn.t()) :: true | false

  @doc """
  Decide if we can `PUT` to a resource that does not exist, or return 501 Not Implemented.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback can_put_to_missing?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-None-Match` header exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_none_match_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-None-Match` header is `*`.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_none_match_star?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the etag of the current resource matches the `If-Match-None` header.

  By default, checks the header against the value returned by `c:etag/1`.
  """
  @doc since: "1.0"
  @callback etag_matches_for_if_none?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method to handle failed if-none-match.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_none_match?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-Match` header exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_match_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-Match` header is  `*`.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_match_star?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the etag for the current resource matches the value in the `If-Match` header.

  By default, checks the header against the value returned by `c:etag/1`.
  """
  @doc since: "1.0"
  @callback etag_matches_for_if_match?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-Match *` header exists for a resource that does not exist.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_match_star_exists_for_missing?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-Modified-Since` header exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_modified_since_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-Modified-Since` header is a valid HTTP date.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_modified_since_valid_date?(Plug.Conn.t()) :: true | false

  @doc """
  Checks if the resource was modified since the date given in the `If-Modified-Since` header.

  By default, checks the header against the value returned by `c:last_modified/1`.
  """
  @doc since: "1.0"
  @callback modified_since?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-Unmodified-Since` header exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_unmodified_since_exists?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `If-Unmodified-Since` header is a valid HTTP date.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback if_unmodified_since_valid_date?(Plug.Conn.t()) :: true | false

  @doc """
  Checks if the resource was not modified since the date given in the `If-Unmodified-Since` header.

  By default, checks the header against the value returned by `c:last_modified/1`.
  """
  @doc since: "1.0"
  @callback unmodified_since?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is `DELETE`.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback method_delete?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `DELETE` request was processed.
  Return `false` here if the request was put on some processing queue and the
  delete was not actually enacted yet.
  Returning `false` here would return a 202 Accepted instead of some other response.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback delete_enacted?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is `PATCH`.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback method_patch?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `PATCH` request was processed.
  Return `false` here if the request was put on some processing queue and the
  patch was not actually enacted yet.
  Returning `false` here would return a 202 Accepted instead of some other response.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback patch_enacted?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is `POST`.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback method_post?(Plug.Conn.t()) :: true | false

  @doc """
  Decide if the response should redirect after a `POST`.

  By default, always returns `false`.
  """
  @doc since: "1.0"
  @callback post_redirect?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is `POST` for a resource that already exists.

  Used internally; it is not advised to override this function.
  """
  @doc since: "1.0"
  @callback post_to_existing?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `POST` request was processed.
  Return `false` here if the request was put on some processing queue and the
  post was not actually enacted yet.
  Returning `false` here would return a 202 Accepted instead of some other response.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback post_enacted?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the request method is a `PUT` for a resource that already exists.
  """
  @doc since: "1.0"
  @callback put_to_existing?(Plug.Conn.t()) :: true | false

  @doc """
  Check if the `PUT` request was processed.
  Return `false` here if the request was put on some processing queue and the
  put was not actually enacted yet.
  Returning `false` here would return a 202 Accepted instead of some other response.

  By default, always returns `true`.
  """
  @doc since: "1.0"
  @callback put_enacted?(Plug.Conn.t()) :: true | false

  @doc """
  Should the response contain a representation of the resource?
  """
  @doc since: "1.0"
  @callback respond_with_entity?(Plug.Conn.t()) :: true | false

  @doc """
  Check if there are multiple representations of the resource.
  """
  @doc since: "1.0"
  @callback multiple_representations?(Plug.Conn.t()) :: true | false

  @doc """
  Does the `PUT` or `POST` request result in a conflict?
  """
  @doc since: "1.0"
  @callback conflict?(Plug.Conn.t()) :: true | false

  @doc """
  Was the resource created by this request?
  """
  @doc since: "1.0"
  @callback new?(Plug.Conn.t()) :: true | false

  @doc """
  A hook invoked at the beginning of the decision tree to set up anything you may need.

  You can return a map here and it will be merged with the given conn's `:assigns` map.
  """
  @doc since: "1.0"
  @callback initialize(Plug.Conn.t()) :: any()

  @doc """
  Called for `DELETE` requests.
  """
  @doc since: "1.0"
  @callback delete!(Plug.Conn.t()) :: any()

  @doc """
  Called for `PUT` requests.
  """
  @doc since: "1.0"
  @callback put!(Plug.Conn.t()) :: any()

  @doc """
  Called for `PATCH` requests.
  """
  @doc since: "1.0"
  @callback patch!(Plug.Conn.t()) :: any()

  @doc """
  Called for `POST` requests.
  """
  @doc since: "1.0"
  @callback post!(Plug.Conn.t()) :: any()

  @doc """
  Returns content for a `200 OK` response.
  """
  @doc since: "1.0"
  @callback handle_ok(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `200 OK` response to an `OPTIONS` request.
  """
  @doc since: "1.0"
  @callback handle_options(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `201 Created` response.
  """
  @doc since: "1.0"
  @callback handle_created(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `202 Accepted` response.
  """
  @doc since: "1.0"
  @callback handle_accepted(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `204 No Content` response.
  """
  @doc since: "1.0"
  @callback handle_no_content(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `300 Multiple Representations` response.
  """
  @doc since: "1.0"
  @callback handle_multiple_representations(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `301 Moved Permanently` response.
  """
  @doc since: "1.0"
  @callback handle_moved_permanently(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `303 See Other` response.
  """
  @doc since: "1.0"
  @callback handle_see_other(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `304 Not Modified` response.
  """
  @doc since: "1.0"
  @callback handle_not_modified(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `307 Moved Permanently` response.
  """
  @doc since: "1.0"
  @callback handle_moved_temporarily(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `400 Malformed` response.
  """
  @doc since: "1.0"
  @callback handle_malformed(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `401 Unauthorized` response.
  """
  @doc since: "1.0"
  @callback handle_unauthorized(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `402 Payment Required` response.

  Please note that the 402 status code is experimental, and is "reserved for future use."
  """
  @doc since: "1.2"
  @callback handle_payment_required(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `403 Forbidden` response.
  """
  @doc since: "1.0"
  @callback handle_forbidden(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `404 Not Found` response.
  """
  @doc since: "1.0"
  @callback handle_not_found(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `405 Method Not Allowed` response.
  """
  @doc since: "1.0"
  @callback handle_method_not_allowed(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `406 Not Acceptable` response.
  """
  @doc since: "1.0"
  @callback handle_not_acceptable(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `409 Conflict` response.
  """
  @doc since: "1.0"
  @callback handle_conflict(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `410 Gone` response.
  """
  @doc since: "1.0"
  @callback handle_gone(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `412 Precondition Failed` response.
  """
  @doc since: "1.0"
  @callback handle_precondition_failed(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `413 Entity Too Large` response.
  """
  @doc since: "1.0"
  @callback handle_request_entity_too_large(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `414 URI Too Long` response.
  """
  @doc since: "1.0"
  @callback handle_uri_too_long(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `415 Unsuppported Media Type` response.
  """
  @doc since: "1.0"
  @callback handle_unsupported_media_type(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `422 Unprocesable Entity` response.
  """
  @doc since: "1.0"
  @callback handle_unprocessable_entity(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `429 Too Many Requests` response.

  For more information on this response type, see [RFC 6585, section 4](https://tools.ietf.org/html/rfc6585#section-4).
  """
  @doc since: "1.2"
  @callback handle_too_many_requests(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `451 Unavailable for Legal Reasons` response.

  For more information on this response type, see [RFC 7725](https://tools.ietf.org/html/rfc7725).
  """
  @doc since: "1.2"
  @callback handle_unavailable_for_legal_reasons(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns a conn for a `500 Internal Server Error` response.

  This handler is special among the handlers.
  Not only does it receive the `conn`, it also receives the error that was thrown,
  as well as the atom name of the failed step.
  """
  @doc since: "1.4"
  @callback handle_error(Plug.Conn.t(), term, atom) :: Plug.Conn.t()

  @doc """
  Returns content for a `501 Unknown Method` response.
  """
  @doc since: "1.0"
  @callback handle_unknown_method(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `501 Not Implemented` response.
  """
  @doc since: "1.0"
  @callback handle_not_implemented(Plug.Conn.t()) :: Plug.Conn.t()

  @doc """
  Returns content for a `503 Service Unavailable` response.
  """
  @doc since: "1.0"
  @callback handle_service_unavailable(Plug.Conn.t()) :: Plug.Conn.t()

  def put_liberator_module(conn, module) do
    put_private(conn, :liberator_module, module)
  end

  def put_decision_tree_overrides(conn, overrides) do
    put_private(
      conn,
      :liberator_decisions,
      Map.merge(Liberator.Default.DecisionTree.decisions(), overrides)
    )
  end

  def put_action_followup_overrides(conn, overrides) do
    put_private(
      conn,
      :liberator_actions,
      Map.merge(Liberator.Default.DecisionTree.actions(), overrides)
    )
  end

  def put_handler_status_overrides(conn, overrides) do
    put_private(
      conn,
      :liberator_handlers,
      Map.merge(Liberator.Default.DecisionTree.handlers(), overrides)
    )
  end

  defmacro __using__(usage_opts) do
    # I wish I could find a way to make this shorter, but I don't think I can!
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      use Plug.Builder
      import Liberator.Resource
      @behaviour Liberator.Resource

      plug(:put_liberator_module, __MODULE__)

      plug(
        :put_decision_tree_overrides,
        Keyword.get(unquote(usage_opts), :decision_tree_overrides, %{})
      )

      plug(
        :put_action_followup_overrides,
        Keyword.get(unquote(usage_opts), :action_followup_overrides, %{})
      )

      plug(
        :put_handler_status_overrides,
        Keyword.get(unquote(usage_opts), :handler_status_overrides, %{})
      )

      plug(Liberator.Evaluator, unquote(usage_opts))

      @impl true
      def allowed_methods(_conn) do
        ["GET", "HEAD"]
      end

      @impl true
      def known_methods(_conn) do
        ["GET", "HEAD", "OPTIONS", "PUT", "POST", "DELETE", "PATCH", "TRACE"]
      end

      @impl true
      def available_media_types(_conn) do
        ["text/plain"]
      end

      @impl true
      def available_languages(_conn) do
        ["*"]
      end

      @impl true
      def available_charsets(_conn) do
        ["UTF-8"]
      end

      @impl true
      def available_encodings(_conn) do
        ["gzip", "deflate", "identity"]
      end

      @impl true
      def maximum_entity_length(_conn) do
        64_000
      end

      @impl true
      def last_modified(_conn) do
        DateTime.utc_now()
      end

      @impl true
      def etag(_conn) do
        nil
      end

      @impl true
      def service_available?(_conn), do: true
      @impl true
      def known_method?(conn) do
        conn.method in known_methods(conn)
      end

      @impl true
      def uri_too_long?(_conn), do: false
      @impl true
      def method_allowed?(conn) do
        conn.method in allowed_methods(conn)
      end

      @impl true
      def well_formed?(_conn), do: true
      @impl true
      def malformed?(_conn), do: false
      @impl true
      def payment_required?(_conn), do: false
      @impl true
      def authorized?(_conn), do: true
      @impl true
      def allowed?(_conn), do: true
      @impl true
      def too_many_requests?(_conn), do: false
      @impl true
      def valid_content_header?(_conn), do: true
      @impl true
      def known_content_type?(_conn), do: true

      @impl true
      def body_exists?(conn) do
        conn = Liberator.Conn.read_body(conn, length: maximum_entity_length(conn))
        body = conn.assigns[:raw_body]

        unless body == :too_large or is_nil(body) or body == <<>> do
          conn
        end
      end

      @impl true
      def valid_entity_length?(conn) do
        conn.assigns[:raw_body] != :too_large
      end

      @impl true

      @impl true
      def is_options?(conn), do: conn.method == "OPTIONS"
      @impl true
      def method_put?(conn), do: conn.method == "PUT"
      @impl true
      def method_post?(conn), do: conn.method == "POST"
      @impl true
      def method_delete?(conn), do: conn.method == "DELETE"
      @impl true
      def method_patch?(conn), do: conn.method == "PATCH"

      @impl true
      def accept_exists?(conn) do
        get_req_header(conn, "accept") |> Enum.any?()
      end

      @impl true
      def accept_language_exists?(conn) do
        get_req_header(conn, "accept-language") |> Enum.any?()
      end

      @impl true
      def accept_charset_exists?(conn) do
        get_req_header(conn, "accept-charset") |> Enum.any?()
      end

      @impl true
      def accept_encoding_exists?(conn) do
        get_req_header(conn, "accept-encoding") |> Enum.any?()
      end

      @impl true
      def media_type_available?(conn) do
        Liberator.Default.ContentNegotiation.media_type_available?(__MODULE__, conn)
      end

      @impl true
      def language_available?(conn) do
        Liberator.Default.ContentNegotiation.language_available?(__MODULE__, conn)
      end

      @impl true
      def charset_available?(conn) do
        Liberator.Default.ContentNegotiation.charset_available?(__MODULE__, conn)
      end

      @impl true
      def encoding_available?(conn) do
        Liberator.Default.ContentNegotiation.encoding_available?(__MODULE__, conn)
      end

      @impl true
      def processable?(_conn), do: true
      @impl true
      def exists?(_conn), do: true
      @impl true
      def existed?(_conn), do: false
      @impl true
      def moved_permanently?(_conn), do: false
      @impl true
      def moved_temporarily?(_conn), do: false
      @impl true
      def unavailable_for_legal_reasons?(_conn), do: false

      @impl true
      def if_match_star_exists_for_missing?(conn), do: if_match_star?(conn)
      @impl true
      def post_to_missing?(conn), do: method_post?(conn)
      @impl true
      def post_to_existing?(conn), do: method_post?(conn)
      @impl true
      def post_to_gone?(conn), do: method_post?(conn)
      @impl true
      def can_post_to_missing?(_conn), do: true
      @impl true
      def can_post_to_gone?(_conn), do: false
      @impl true
      def put_to_existing?(conn), do: method_put?(conn)
      @impl true
      def can_put_to_missing?(_conn), do: false
      @impl true
      def put_to_different_url?(_conn), do: false

      @impl true
      def if_match_exists?(conn) do
        get_req_header(conn, "if-match") |> Enum.any?()
      end

      @impl true
      def if_match_star?(conn) do
        get_req_header(conn, "if-match") |> Enum.any?(&(&1 == "*"))
      end

      @impl true
      def if_none_match_exists?(conn) do
        get_req_header(conn, "if-none-match") |> Enum.any?()
      end

      @impl true
      def if_none_match_star?(conn) do
        get_req_header(conn, "if-none-match") |> Enum.any?(&(&1 == "*"))
      end

      @impl true
      def if_none_match?(_conn), do: false

      @impl true
      def etag_matches_for_if_match?(conn) do
        if etag = etag(conn) do
          if etag == get_req_header(conn, "if-match") |> Enum.at(0) do
            %{etag: etag}
          end
        end
      end

      @impl true
      def etag_matches_for_if_none?(conn) do
        if etag = etag(conn) do
          if etag == get_req_header(conn, "if-none-match") |> Enum.at(0) do
            %{etag: etag}
          end
        end
      end

      @impl true
      def if_modified_since_exists?(conn) do
        get_req_header(conn, "if-modified-since") |> Enum.any?()
      end

      @impl true
      def if_modified_since_valid_date?(conn) do
        conn
        |> get_req_header("if-modified-since")
        |> Enum.at(0)
        |> Liberator.HTTPDateTime.valid?()
      end

      @impl true
      def modified_since?(conn) do
        conn
        |> get_req_header("if-modified-since")
        |> Enum.at(0)
        |> Liberator.HTTPDateTime.parse!()
        |> Timex.before?(last_modified(conn))
      end

      @impl true
      def if_unmodified_since_exists?(conn) do
        get_req_header(conn, "if-unmodified-since") |> Enum.any?()
      end

      @impl true
      def if_unmodified_since_valid_date?(conn) do
        conn
        |> get_req_header("if-unmodified-since")
        |> Enum.at(0)
        |> Liberator.HTTPDateTime.valid?()
      end

      @impl true
      def unmodified_since?(conn) do
        conn
        |> get_req_header("if-unmodified-since")
        |> Enum.at(0)
        |> Liberator.HTTPDateTime.parse!()
        |> Timex.after?(last_modified(conn))
      end

      @impl true
      def post_redirect?(_conn), do: false
      @impl true
      def post_enacted?(_conn), do: true
      @impl true
      def put_enacted?(_conn), do: true
      @impl true
      def delete_enacted?(_conn), do: true
      @impl true
      def patch_enacted?(_conn), do: true
      @impl true
      def respond_with_entity?(_conn), do: true
      @impl true
      def conflict?(_conn), do: false
      @impl true
      def new?(_conn), do: true
      @impl true
      def multiple_representations?(_conn), do: false

      @impl true
      def initialize(_conn), do: nil

      @impl true
      def delete!(_conn) do
        nil
      end

      @impl true
      def put!(_conn) do
        nil
      end

      @impl true
      def patch!(_conn) do
        nil
      end

      @impl true
      def post!(_conn) do
        nil
      end

      @impl true
      defdelegate handle_ok(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_options(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_created(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_accepted(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_no_content(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_multiple_representations(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_moved_permanently(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_see_other(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_not_modified(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_moved_temporarily(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_malformed(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_payment_required(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_unauthorized(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_forbidden(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_not_found(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_method_not_allowed(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_not_acceptable(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_conflict(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_gone(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_precondition_failed(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_request_entity_too_large(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_uri_too_long(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_unsupported_media_type(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_unprocessable_entity(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_too_many_requests(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_unavailable_for_legal_reasons(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_error(_conn, _error, _failed_step), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_not_implemented(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_unknown_method(_conn), to: Liberator.Default.Handlers

      @impl true
      defdelegate handle_service_unavailable(_conn), to: Liberator.Default.Handlers

      defoverridable Liberator.Resource
    end
  end
end
