defmodule Liberator.Resource do
  use Plug.Builder
  @moduledoc """
  A controller module that understands and respects the HTTP spec.

  This module implements a `Plug` handler that allows an endpoint to comply to the HTTP specification,
  and to do so by just answering a few questions.

  Define a simple resource like this:

      defmodule MyFirstResource do
        use Liberator.Resource

        def available_media_types(_), do: ["text/plain"]
        def handle_ok(conn), do: "Hello world!"
      end

  There are lots of decisions to be made during content negotiation,
  and Liberator lets gives you access to every single one,
  but it's also built with sensible defaults that let you quickly build up a controller.

  ## Content Negotiation

  These functions return lists of available values during content negotiation.
  If the client has an accept header that does not match a value from these lists,
  the plug will return a `406 Not Acceptable` response, and call `c:handle_not_acceptable/1`.

  | Function                    | Default           |
  |-----------------------------|-------------------|
  | `c:allowed_methods/1`       | `["GET", "HEAD"]` |
  | `c:known_methods/1`         | `["GET", "HEAD", "OPTIONS", "PUT", "POST", "DELETE", "PATCH", "TRACE"]` |
  | `c:available_media_types/1` | `[]`              |
  | `c:available_languages/1`   | `["*"]`           |
  | `c:available_charsets/1`    | `["UTF-8"]`       |
  | `c:available_encodings/1`   | `["identity"]`    |

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
  | `c:handle_unknown_method/1`                 | 501 |
  | `c:handle_not_implemented/1`                | 501 |
  | `c:handle_service_unavailable/1`            | 503 |

  ## Decisions

  Liberator supports a whole lot of decisions points.
  Some of them are needed for next to every resource definition.
  Others are seldom used or there is no other sensible implementation.

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
  | `c:malformed?/1`            | Is the request malformed?                                                           | false |
  | `c:media_type_available?/1` | Is the requested media type available? Should assign the `:media_type` variale.     | Uses values at `c:available_media_types/1` |
  | `c:method_allowed?/1`       | Is the request method allowed for this resource?                                    | Uses values at `c:allowed_methods/1` |
  | `c:modified_since?/1`       | Was the resource modified since the date given in the `If-Modified-Since` header?   | Uses value generated by `c:last_modified/1` |
  | `c:moved_permanently?/1`    | Was the resource moved permanently?                                                 | false |
  | `c:moved_temporarily?/1`    | Was the resource moved temporarily?                                                 | false |
  | `c:multiple_representations?/1` | Are there multiple representations for this resource?                           | false |
  | `c:post_enacted?/1`         | Was the `POST` request finally processed?                                           | true |
  | `c:put_enacted?/1`          | Was the `PUT` request finally processed?                                            | true |
  | `c:patch_enacted?/1`        | Was the `PATCH` request finally processed?                                          | true |
  | `c:new?/1`                  | Was the resource created by this request?                                           | true |
  | `c:post_redirect?/1`        | Should the response redirect after a `POST`?                                        | false |
  | `c:put_to_different_url?/1` | Should the `PUT` request be made to a different URL?                                | false |
  | `c:processable?/1`          | Is the request body processable?                                                    | true |
  | `c:service_available?/1`    | Is the service available?                                                           | true |
  | `c:uri_too_long?/1`         | Is the request URI too long?                                                        | false |
  | `c:valid_content_header?/1` | Is the `Content-Type` of the body valid?                                            | true |
  | `c:valid_entity_length?/1`  | Is the length of the body valid?                                                    | true |

  ## Internal Decision Points

  These decision points are used internally by Liberator and provide reasonable defaults.
  Overriding is possible, but not useful in general.

  | Function                                 | Description                                                                    |
  |---                                       |---                                                                             |
  | `c:accept_charset_exists?/1`             | Checks if header `Accept-Charset` exists.                                      |
  | `c:accept_encoding_exists?/1`            | Checks if header `Accept-Encoding` exists.                                     |
  | `c:accept_exists?/1`                     | Checks if header `Accept` exists.                                              |
  | `c:accept_language_exists?/1`            | Checks if header `Accept-Language` exists.                                     |
  | `c:if_match_exists?/1`                   | Checks if header `If-Match` exists.                                            |
  | `c:if_match_star?/1`                     | Checks if header `If-Match` is `*`.                                            |
  | `c:if_match_star_exists_for_missing?/1`  | Checks if header `If-Match` exists for a resource that does not exist.         |
  | `c:if_modified_since?/1`                 | Checks if header `If-Modified-Since` exists.                                   |
  | `c:if_modified_valid_date?/1`            | Checks if header `If-Modified-Since` is a valid HTTP date.                     |
  | `c:if_none_match?/1`                     | Checks if the request method to handle failed `If-None-Match`                  |
  | `c:if_none_match_exists?/1`              | Checks if header `If-None-Match` exists.                                       |
  | `c:if_none_match_star?/1`                | Checks if header `If-None-Match` is `*`.                                       |
  | `c:if_unmodified_since_exists?/1`        | Checks if header `If-Unmodified-Since` exists.                                 |
  | `c:if_unmodified_valid_date?/1`          | Checks if header `If-Unmodified-Since` is a valid HTTP date.                   |
  | `c:is_options?/1`                        | Checks if the request method is `OPTIONS`                                      |
  | `c:method_delete?/1`                     | Checks if the request method is `DELETE`                                       |
  | `c:method_put?/1`                        | Checks if the request method is `PUT`                                          |
  | `c:method_patch?/1`                      | Checks if the request method is `PATCH`                                        |
  | `c:post_to_gone?/1`                      | Checks if the request method is `POST` for resources that do not exist anymore.|
  | `c:post_to_existing?/1`                  | Checks if the request method is `POST` for resources that do exist.            |
  | `c:post_to_missing?/1`                   | Checks if the request method is `POST` for resources that do not exist.        |
  | `c:put_to_existing?/1`                   | Checks if the request method is `PUT` for a resource that exists.              |


  """

  @doc """
  Returns a list of HTTP methods that this module serves.

  The methods returned by this function should be upper-case strings, like `"GET"`, `"POST"`, etc.
  """
  @callback allowed_methods(Plug.Conn.t) :: list()

  @doc """
  Returns a list of HTTP methods that exist.

  Note that this is to filter bad HTTP requests, not to filter requests that your endpoint does not serve.
  You probably want to implement `c:allowed_methods/1` instead.

  The methods returned by this function should be upper-case strings, like `"GET"`, `"POST"`, etc.
  """
  @callback known_methods(Plug.Conn.t) :: list()

  @doc """
  Returns a list of content types that this module serves.

  The types returned by this function should be valid MIME types, like `text/plain`, `application/json`, etc.
  """
  @callback available_media_types(Plug.Conn.t) :: list()

  @doc """
  Returns a list of available languages.
  """
  @callback available_languages(Plug.Conn.t) :: list()

  @doc """
  Returns a list of available response content encodings (AKA compressions).

  By default, only `identity` (no compression) is supported.
  """
  @callback available_encodings(Plug.Conn.t) :: list()

  @doc """
  Returns a list of available content charsets.

  By default, only `UTF-8` is supported.
  """
  @callback available_charsets(Plug.Conn.t) :: list()

  @doc """
  Returns the last modified date of your resource.

  This value will be used to respond to caching headers like `If-Modified-Since`.
  """
  @callback last_modified(Plug.Conn.t) :: DateTime.t

  @doc """
  Returns the etag for the current entity.

  This value will be used to respond to caching headers like `If-None-Match`.
  """
  @callback etag(Plug.Conn.t) :: String.t

  @doc """
  Check if your service is available.

  This is the first function called in the entire pipeline,
  and lets you check to make sure everything works before going deeper.
  If this function returns `false`, then the plug will return a 503 Service Not Available response.

  By default, always returns `true`.
  """
  @callback service_available?(Plug.Conn.t) :: true | false

  @doc """
  Check of the HTTP method in the request is one we know about.

  This is different from `c:allowed_methods/1` in that this function
  checks to see if the given HTTP method is an HTTP method at all.
  You probably want to override `c:allowed_methods/1` and not this one,
  unless you're extending HTTP with more verbs.

  If this function returns `false`, then the plug will return a 501 Unknown Method response.

  By default, allows the methods returned by `c:known_methods/1`.
  """
  @callback known_method?(Plug.Conn.t) :: true | false

  @doc """
  Checks the length of the URI.

  If this function returns true, then the plug will return a 414 URI Too Long response.

  By default, always returns `false`.
  """
  @callback uri_too_long?(Plug.Conn.t) :: true | false

  @doc """
  Check if the server supports the request's HTTP method.

  Override `c:allowed_methods/1` instead of this function to let this plug perform the check for you.

  By default, allows the methods returned by `c:allowed_methods/1`.
  """
  @callback method_allowed?(Plug.Conn.t) :: true | false

  @doc """
  Check the request for general adherence to some form.

  If this function returns false, then the plug will return a 400 Malformed response.

  If you're checking the body of a request against some schema,
  you should override `c:processable?/1` instead.

  By default, always returns `false`.
  """
  @callback malformed?(Plug.Conn.t) :: true | false

  @doc """
  Check for presence ofauthentication information in the request.

  Note the difference between `c:authorized?/1` and `c:allowed?/1`.
  This function should just check for the presence of authentication information,
  not the content of it.

  If you implement this function to return `false`, your response in `handle_unauthorized`
  must include a `WWW-Authenticate` header field containing a challenge applicable to the requested resource.

  By default, always returns `true`.
  """
  @callback authorized?(Plug.Conn.t) :: true | false

  @doc """
  Check the authentication information in the request to see if it has the necessary permissions.

  Note the difference between `c:authorized?/1` and `c:allowed?/1`.
  This function checks if the given request is allowed to perform an action,
  but isn't responsible for checking the presence of authentication information in the first place.

  By default, always returns `true`.
  """
  @callback allowed?(Plug.Conn.t) :: true | false

  @doc """
  Check if the Content-Type of the body is valid.

  By default, always returns `true`.
  """
  @callback valid_content_header?(Plug.Conn.t) :: true | false

  @doc """
  Check if the Content-Type of the body is known.

  By default, always returns `true`.
  """
  @callback known_content_type?(Plug.Conn.t) :: true | false

  @doc """
  Check if the length of the body is valid.

  By default, always returns `true`.
  """
  @callback valid_entity_length?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is Options.

  Used internally; it is not advised to override this function.
  """
  @callback is_options?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `Accept` header exists.

  Used internally; it is not advised to override this function.
  """
  @callback accept_exists?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request media type is available.

  By default, uses the values returned by `c:available_media_types/1`.
  """
  @callback media_type_available?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `Accept-Language` header exists.

  Used internally; it is not advised to override this function.
  """
  @callback accept_language_exists?(Plug.Conn.t) :: true | false

  @doc """
  Check if the requested language is available.

  By default, uses the values returned by `c:available_languages/1`.
  """
  @callback language_available?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `Accept-Charset` header exists.

  Used internally; it is not advised to override this function.
  """
  @callback accept_charset_exists?(Plug.Conn.t) :: true | false

  @doc """
  Check of the requested charset is available.

  By default, uses the values returned by `c:available_charsets/1`.
  """
  @callback charset_available?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `Accept-Encoding` header exists.

  Used internally; it is not advised to override this function.
  """
  @callback accept_encoding_exists?(Plug.Conn.t) :: true | false

  @doc """
  Check of the requested encoding is available.

  By default, uses the values returned by `c:available_encodings/1`.
  """
  @callback encoding_available?(Plug.Conn.t) :: true | false

  @doc """
  Check if the body of the request can be processed.

  This is a good place to parse a JSON body if that's what you're doing.
  Returning `false` here would cause the plug to return a 422 Unprocessable response.
  """
  @callback processable?(Plug.Conn.t) :: true | false

  @doc """
  Check if the requested entity exists.

  This is a great place to actually fetch the requested resource,
  then return it as a map so it can be merged into the `:assigns` map of the request.

  Returning `false` here will cause the plug to return a 404 Not Found response.
  """
  @callback exists?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is `PUT`.

  Used internally; it is not advised to override this function.
  """
  @callback method_put?(Plug.Conn.t) :: true | false

  @doc """
  Check if the resource ever existed.

  Answering `true` here will lead you down the path that leads to
  responses like "Moved Permanently" and "Gone", among othes.
  """
  @callback existed?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is `POST` to a resource that doesn't exist.

  Used internally; it is not advised to override this function.
  """
  @callback post_to_missing?(Plug.Conn.t) :: true | false

  @doc """
  Check if we can process a post to a resource that does not exist,
  or if we should send a 404 Not Found response.

  By default, always returns `true`.
  """
  @callback can_post_to_missing?(Plug.Conn.t) :: true | false

  @doc """
  Check if the resource was moved permanently.

  By default, always returns `false`.
  """
  @callback moved_permanently?(Plug.Conn.t) :: true | false

  @doc """
  Check if the resource was moved temporarily.

  By default, always returns `false`.
  """
  @callback moved_temporarily?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is `POST` for resources that do not exist anymore.

  Used internally; it is not advised to override this function.
  """
  @callback post_to_gone?(Plug.Conn.t) :: true | false

  @doc """
  Decide if we can process a `POST` to a resource that existed before, or return a 410 Gone response.

  By default, always returns `false`.
  """
  @callback can_post_to_gone?(Plug.Conn.t) :: true | false

  @doc """
  Decide if a `PUT` request should be made to a different URL.

  By default, always returns `false`.
  """
  @callback put_to_different_url?(Plug.Conn.t) :: true | false

  @doc """
  Decide if we can `PUT` to a resource that does not exist, or return 501 Not Implemented.

  By default, always returns `true`.
  """
  @callback can_put_to_missing?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-None-Match` header exists.

  Used internally; it is not advised to override this function.
  """
  @callback if_none_match_exists?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-None-Match` header is `*`.

  Used internally; it is not advised to override this function.
  """
  @callback if_none_match_star?(Plug.Conn.t) :: true | false

  @doc """
  Check if the etag of the current resource matches the `If-Match-None` header.

  By default, checks the header against the value returned by `c:etag/1`.
  """
  @callback etag_matches_for_if_none?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method to handle failed if-none-match.

  Used internally; it is not advised to override this function.
  """
  @callback if_none_match?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-Match` header exists.

  Used internally; it is not advised to override this function.
  """
  @callback if_match_exists?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-Match` header is  `*`.

  Used internally; it is not advised to override this function.
  """
  @callback if_match_star?(Plug.Conn.t) :: true | false

  @doc """
  Check if the etag for the current resource matches the value in the `If-Match` header.

  By default, checks the header against the value returned by `c:etag/1`.
  """
  @callback etag_matches_for_if_match?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-Match *` header exists for a resource that does not exist.

  Used internally; it is not advised to override this function.
  """
  @callback if_match_star_exists_for_missing?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-Modified-Since` header exists.

  Used internally; it is not advised to override this function.
  """
  @callback if_modified_since_exists?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-Modified-Since` header is a valid HTTP date.

  Used internally; it is not advised to override this function.
  """
  @callback if_modified_since_valid_date?(Plug.Conn.t) :: true | false

  @doc """
  Checks if the resource was modified since the date given in the `If-Modified-Since` header.

  By default, checks the header against the value returned by `c:last_modified/1`.
  """
  @callback modified_since?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-Unmodified-Since` header exists.

  Used internally; it is not advised to override this function.
  """
  @callback if_unmodified_since_exists?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `If-Unmodified-Since` header is a valid HTTP date.

  Used internally; it is not advised to override this function.
  """
  @callback if_unmodified_since_valid_date?(Plug.Conn.t) :: true | false

  @doc """
  Checks if the resource was not modified since the date given in the `If-Unmodified-Since` header.

  By default, checks the header against the value returned by `c:last_modified/1`.
  """
  @callback unmodified_since?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is `DELETE`.

  Used internally; it is not advised to override this function.
  """
  @callback method_delete?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `DELETE` request was processed.
  Return `false` here if the request was put on some processing queue and the
  delete was not actually enacted yet.
  Returning `false` here would return a 202 Accepted instead of some other response.

  By default, always returns `true`.
  """
  @callback delete_enacted?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is `PATCH`.

  Used internally; it is not advised to override this function.
  """
  @callback method_patch?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `PATCH` request was processed.
  Return `false` here if the request was put on some processing queue and the
  patch was not actually enacted yet.
  Returning `false` here would return a 202 Accepted instead of some other response.

  By default, always returns `true`.
  """
  @callback patch_enacted?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is `POST`.

  Used internally; it is not advised to override this function.
  """
  @callback method_post?(Plug.Conn.t) :: true | false

  @doc """
  Decide if the response should redirect after a `POST`.

  By default, always returns `false`.
  """
  @callback post_redirect?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is `POST` for a resource that already exists.

  Used internally; it is not advised to override this function.
  """
  @callback post_to_existing?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `POST` request was processed.
  Return `false` here if the request was put on some processing queue and the
  post was not actually enacted yet.
  Returning `false` here would return a 202 Accepted instead of some other response.

  By default, always returns `true`.
  """
  @callback post_enacted?(Plug.Conn.t) :: true | false

  @doc """
  Check if the request method is a `PUT` for a resource that already exists.
  """
  @callback put_to_existing?(Plug.Conn.t) :: true | false

  @doc """
  Check if the `PUT` request was processed.
  Return `false` here if the request was put on some processing queue and the
  put was not actually enacted yet.
  Returning `false` here would return a 202 Accepted instead of some other response.

  By default, always returns `true`.
  """
  @callback put_enacted?(Plug.Conn.t) :: true | false

  @doc """
  Should the response contain a representation of the resource?
  """
  @callback respond_with_entity?(Plug.Conn.t) :: true | false

  @doc """
  Check if there are multiple representations of the resource.
  """
  @callback multiple_representations?(Plug.Conn.t) :: true | false

  @doc """
  Does the `PUT` or `POST` request result in a conflict?
  """
  @callback conflict?(Plug.Conn.t) :: true | false

  @doc """
  Was the resource created by this request?
  """
  @callback new?(Plug.Conn.t) :: true | false

  @callback initialize(Plug.Conn.t) :: any()

  @doc """
  Called for `DELETE` requests.
  """
  @callback delete!(Plug.Conn.t) :: any()

  @doc """
  Called for `PUT` requests.
  """
  @callback put!(Plug.Conn.t) :: any()

  @doc """
  Called for `PATCH` requests.
  """
  @callback patch!(Plug.Conn.t) :: any()

  @doc """
  Called for `POST` requests.
  """
  @callback post!(Plug.Conn.t) :: any()


  @doc """
  Returns content for a `200 OK` response.
  """
  @callback handle_ok(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `200 OK` response to an `OPTIONS` request.
  """
  @callback handle_options(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `201 Created` response.
  """
  @callback handle_created(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `202 Accepted` response.
  """
  @callback handle_accepted(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `204 No Content` response.
  """
  @callback handle_no_content(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `300 Multiple Representations` response.
  """
  @callback handle_multiple_representations(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `301 Moved Permanently` response.
  """
  @callback handle_moved_permanently(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `303 See Other` response.
  """
  @callback handle_see_other(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `304 Not Modified` response.
  """
  @callback handle_not_modified(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `307 Moved Permanently` response.
  """
  @callback handle_moved_temporarily(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `400 Malformed` response.
  """
  @callback handle_malformed(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `401 Unauthorized` response.
  """
  @callback handle_unauthorized(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `403 Forbidden` response.
  """
  @callback handle_forbidden(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `404 Not Found` response.
  """
  @callback handle_not_found(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `405 Method Not Allowed` response.
  """
  @callback handle_method_not_allowed(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `406 Not Acceptable` response.
  """
  @callback handle_not_acceptable(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `409 Conflict` response.
  """
  @callback handle_conflict(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `410 Gone` response.
  """
  @callback handle_gone(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `412 Precondition Failed` response.
  """
  @callback handle_precondition_failed(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `413 Entity Too Large` response.
  """
  @callback handle_request_entity_too_large(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `414 URI Too Long` response.
  """
  @callback handle_uri_too_long(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `415 Unsuppported Media Type` response.
  """
  @callback handle_unsupported_media_type(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `422 Unprocesable Entity` response.
  """
  @callback handle_unprocessable_entity(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `501 Unknown Method` response.
  """
  @callback handle_unknown_method(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `501 Not Implemented` response.
  """
  @callback handle_not_implemented(Plug.Conn.t) :: Plug.Conn.t

  @doc """
  Returns content for a `503 Service Unavailable` response.
  """
  @callback handle_service_unavailable(Plug.Conn.t) :: Plug.Conn.t

  defmacro __using__(_opts) do
    quote do
      use Plug.Builder
      use Timex
      @behaviour Liberator.Resource

      @decisions %{
        service_available?: {:known_method?, :handle_service_unavailable},
        known_method?: {:uri_too_long?, :handle_unknown_method},
        uri_too_long?: {:handle_uri_too_long, :method_allowed?},
        method_allowed?: {:malformed?, :handle_method_not_allowed},
        malformed?: {:handle_malformed, :authorized?},
        authorized?: {:allowed?, :handle_unauthorized},
        allowed?: {:valid_content_header?, :handle_forbidden},
        valid_content_header?: {:known_content_type?, :handle_not_implemented},
        known_content_type?: {:valid_entity_length?, :handle_unsupported_media_type},
        valid_entity_length?: {:is_options?, :handle_request_entity_too_large},
        is_options?: {:handle_options, :accept_exists?},
        accept_exists?: {:media_type_available?, :accept_language_exists?},
        media_type_available?: {:accept_language_exists?, :handle_not_acceptable},
        accept_language_exists?: {:language_available?, :accept_charset_exists?},
        language_available?: {:accept_charset_exists?, :handle_not_acceptable},
        accept_charset_exists?: {:charset_available?, :accept_encoding_exists?},
        charset_available?: {:accept_encoding_exists?, :handle_not_acceptable},
        accept_encoding_exists?: {:encoding_available?, :processable?},
        encoding_available?: {:processable?, :handle_not_acceptable},
        processable?: {:exists?, :handle_unprocessable_entity},
        exists?: {:if_match_exists?, :if_match_star_exists_for_missing?},
        if_match_exists?: {:if_match_star?, :if_unmodified_since_exists?},
        if_match_star?: {:if_unmodified_since_exists?, :etag_matches_for_if_match?},
        etag_matches_for_if_match?: {:if_unmodified_since_exists?, :handle_precondition_failed},
        if_unmodified_since_exists?: {:if_unmodified_since_valid_date?, :if_none_match_exists?},
        if_unmodified_since_valid_date?: {:unmodified_since?, :if_none_match_exists?},
        unmodified_since?: {:handle_precondition_failed, :if_none_match_exists?},
        if_none_match_exists?: {:if_none_match_star?, :if_modified_since_exists?},
        if_none_match_star?: {:if_none_match?, :etag_matches_for_if_none?},
        etag_matches_for_if_none?: {:if_none_match?, :if_modified_since_exists?},
        if_none_match?: {:handle_not_modified, :handle_precondition_failed},
        if_modified_since_exists?: {:if_modified_since_valid_date?, :method_delete?},
        if_modified_since_valid_date?: {:modified_since?, :method_delete?},
        modified_since?: {:method_delete?, :handle_not_modified},
        if_match_star_exists_for_missing?: {:handle_precondition_failed, :method_put?},
        method_put?: {:put_to_different_url?, :existed?},
        put_to_different_url?: {:handle_moved_permanently, :can_put_to_missing?},
        can_put_to_missing?: {:conflict?, :handle_not_implemented},
        existed?: {:moved_permanently?, :post_to_missing?},
        moved_permanently?: {:handle_moved_permanently, :moved_temporarily?},
        moved_temporarily?: {:handle_moved_temporarily, :post_to_gone?},
        post_to_gone?: {:can_post_to_gone?, :handle_gone},
        can_post_to_gone?: {:post!, :handle_gone},
        post_to_missing?: {:can_post_to_missing?, :handle_not_found},
        can_post_to_missing?: {:post!, :handle_not_found},
        method_delete?: {:delete!, :method_patch?},
        method_patch?: {:patch!, :post_to_existing?},
        post_to_existing?: {:conflict?, :put_to_existing?},
        put_to_existing?: {:conflict?, :multiple_representations?},
        conflict?: {:handle_conflict, :method_post?},
        method_post?: {:post!, :put!},
        delete_enacted?: {:respond_with_entity?, :handle_accepted},
        put_enacted?: {:new?, :handle_accepted},
        patch_enacted?: {:respond_with_entity?, :handle_accepted},
        post_enacted?: {:post_redirect?, :handle_accepted},
        post_redirect?: {:handle_see_other, :new?},
        new?: {:handle_created, :respond_with_entity?},
        respond_with_entity?: {:multiple_representations?, :handle_no_content},
        multiple_representations?: {:handle_multiple_representations, :handle_ok}
      }

      @actions %{
        initialize: :service_available?,
        delete!: :delete_enacted?,
        put!: :put_enacted?,
        patch!: :patch_enacted?,
        post!: :post_enacted?
      }

      @handlers %{
        handle_ok: 200,
        handle_options: 200,
        handle_created: 201,
        handle_accepted: 202,
        handle_no_content: 204,
        handle_multiple_representations: 300,
        handle_moved_permanently: 301,
        handle_see_other: 303,
        handle_not_modified: 304,
        handle_moved_temporarily: 307,
        handle_malformed: 400,
        handle_unauthorized: 401,
        handle_forbidden: 403,
        handle_not_found: 404,
        handle_method_not_allowed: 405,
        handle_not_acceptable: 406,
        handle_conflict: 409,
        handle_gone: 410,
        handle_precondition_failed: 412,
        handle_request_entity_too_large: 413,
        handle_uri_too_long: 414,
        handle_unsupported_media_type: 415,
        handle_unprocessable_entity: 422,
        handle_unknown_method: 501,
        handle_not_implemented: 501,
        handle_service_unavailable: 503
      }

      plug :start

      defp start(conn, opts) do
        continue(conn, :initialize, opts)
      end

      defp continue(conn, next_step, opts) do
        cond do
          Map.has_key?(@decisions, next_step) ->
            {true_step, false_step} = @decisions[next_step]
            if result = apply(__MODULE__, next_step, [conn]) do
              conn = merge_map_assigns(conn, result)
              continue(conn, true_step, opts)
            else
              continue(conn, false_step, opts)
            end
          Map.has_key?(@actions, next_step) ->
            apply(__MODULE__, next_step, [conn])
            continue(conn, @actions[next_step], opts)
          Map.has_key?(@handlers, next_step) ->
            status = @handlers[next_step]
            body = apply(__MODULE__, next_step, [conn])

            encoded_body = case conn.assigns[:media_type] do
              "application/json" -> Jason.encode!(body)
              _ -> body
            end

            send_resp(conn, status, encoded_body)
          true ->
            raise "Unknown step #{inspect next_step}"
        end
      end

      defp merge_map_assigns(conn, result) do
        if is_map(result) do
          merge_assigns(conn, Enum.to_list(result))
        else
          conn
        end
      end

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
        []
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
        ["identity"]
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
      def malformed?(_conn), do: false
      @impl true
      def authorized?(_conn), do: true
      @impl true
      def allowed?(_conn), do: true
      @impl true
      def valid_content_header?(_conn), do: true
      @impl true
      def known_content_type?(_conn), do: true
      @impl true
      def valid_entity_length?(_conn), do: true
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
        accept_something(conn, :media_type, "accept", available_media_types(conn))
      end
      @impl true
      def language_available?(conn) do
        accept_something(conn, :language, "accept-language", available_languages(conn))
      end

      @impl true
      def charset_available?(conn) do
        accept_something(conn, :charset, "accept-charset", available_charsets(conn))
      end
      @impl true
      def encoding_available?(conn) do
        accept_something(conn, :encoding, "accept-encoding", available_encodings(conn))
      end

      defp accept_something(conn, key, header_name, available_values) do
        val =
          available_values
          |> Enum.zip(get_req_header(conn, header_name))
          |> Enum.filter(fn {av, req} -> String.starts_with?(req, av) or "*" in available_values end)
          |> Enum.map(fn {av, req} -> req end)
          |> Enum.take(1)
          |> Map.new(fn c -> {key, c} end)

        if Enum.any?(val) do
          val
        else
          false
        end
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
        |> Timex.parse("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
        |> case do
          {:ok, _time} -> true
          _ -> false
        end
      end
      @impl true
      def modified_since?(conn) do
        conn
        |> get_req_header("if-modified-since")
        |> Enum.at(0)
        |> Timex.parse!("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
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
        |> Timex.parse("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
        |> case do
          {:ok, _time} -> true
          _ -> false
        end
      end
      @impl true
      def unmodified_since?(conn) do
        conn
        |> get_req_header("if-unmodified-since")
        |> Enum.at(0)
        |> Timex.parse!("%a, %d20 %b %Y %H:%M:%S GMT", :strftime)
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
      def handle_ok(conn) do
        "OK"
      end

      @impl true
      def handle_options(conn) do
        "Options"
      end

      @impl true
      def handle_created(conn) do
        "Created"
      end

      @impl true
      def handle_accepted(conn) do
        "Accepted"
      end

      @impl true
      def handle_no_content(conn) do
        "No Content"
      end

      @impl true
      def handle_multiple_representations(conn) do
        "Multiple Representations"
      end

      @impl true
      def handle_moved_permanently(conn) do
        "Moved Permanently"
      end

      @impl true
      def handle_see_other(conn) do
        "See Other"
      end

      @impl true
      def handle_not_modified(conn) do
        "Not Modified"
      end

      @impl true
      def handle_moved_temporarily(conn) do
        "Moved Temporarily"
      end

      @impl true
      def handle_malformed(conn) do
        "Malformed"
      end

      @impl true
      def handle_unauthorized(conn) do
        "Unauthorized"
      end

      @impl true
      def handle_forbidden(conn) do
        "Forbidden"
      end

      @impl true
      def handle_not_found(conn) do
        "Not Found"
      end

      @impl true
      def handle_method_not_allowed(conn) do
        "Method Not Allowed"
      end

      @impl true
      def handle_not_acceptable(conn) do
        "Not Acceptable"
      end

      @impl true
      def handle_conflict(conn) do
        "Conflict"
      end

      @impl true
      def handle_gone(conn) do
        "Gone"
      end

      @impl true
      def handle_precondition_failed(conn) do
        "Precondition Failed"
      end

      @impl true
      def handle_request_entity_too_large(conn) do
        "Request Entity Too Large"
      end

      @impl true
      def handle_uri_too_long(conn) do
        "URI Too Long"
      end

      @impl true
      def handle_unsupported_media_type(conn) do
        "Unsupported Media Type"
      end

      @impl true
      def handle_unprocessable_entity(conn) do
        "Unprocessable Entity"
      end

      @impl true
      def handle_not_implemented(conn) do
        "Not Implemented"
      end

      @impl true
      def handle_unknown_method(conn) do
        "Unknown Method"
      end

      @impl true
      def handle_service_unavailable(conn) do
        "Service Unavailable"
      end

      defoverridable Liberator.Resource
    end
  end
end
