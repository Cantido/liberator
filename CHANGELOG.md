# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## Added
- Internationalization is now supported via `Gettext`!
  Liberator already finds the best language for each request,
  now it also sets the locale using `Gettext.put_locale/1`.
  Just call `gettext` directly in your Resources.
  ([#8](https://github.com/Cantido/liberator/issues/8),
  [#10](https://github.com/Cantido/liberator/pull/10))
- You can now return the given conn in decision functions and actions to serve as an affirmative response,
  as an alternative to returning a plain map, or `true`.
  Now you can modify the conn as you see fit.
- The `maximum_entity_length/1` function.
  This is used by the `valid_entity_length?/1` callback.
  If the size of the request body is above this size,
  Liberator will return a status of `413 Request Entity Too Large`.
- The `Liberator.Conn` module, for working with `Plug.Conn` structs.
  Right now it contains only one function: `read_body/1`,
  which reads the request body and stores it in `conn.assigns[:raw_body]`.
  This is called by the new default implementation of `valid_entity_length?/1` (see **Changed**, below),
  so you will have the body content in `conn.assigns` by default.
- Added the `body_exists?/1` function.
  This is an internal function that, uh, checks to see if the body exists.
  If it does, it'll grab it, and call `valid_entity_length?/1` and
  the new `well_formed?/1` function.
  So now you can parse the body if it's there,
  without worrying about conditional logic if it's not there.
- The `Vary` header is now served by default,
  with a value of `Accept-Encoding` and `Accept-Language`.
- The `etag` header is now included in the response, if you have overridden it.
  ([#17](https://github.com/Cantido/liberator/issues/17))
- Now serves the `last-modified` header based on the return value from the `last_modified/1` callback.
  ([#18](https://github.com/Cantido/liberator/issues/18))
- Now serves the `location` header if you've returned a map with the `:location` key, or assigned it on the conn.
- Tracing individual step duration is now available.
Access the `:duration` key for each decision in the tracing list to get that decision's duration, in native time units.

## Changed
- Some decision functions were rearranged.
- Raised errors are now wrapped in custom exceptions.
They're the same errors with the same messages, just with different wrapper types.
- Entries in the trace list have changed from tuples to maps in order to support more tracing information.
The step is now a map member named `:step`, and the value is `:value`

## Deprecated
- The `malformed?/1` is now deprecated, use `well_formed?/1` instead.
  This lets that decision function return data,
  and it's the ideal place for parsing the body. ([#15](https://github.com/Cantido/liberator/issues/15))

## Fixed
- Non-printable-`String` return values from handlers will now be passed through `inspect/1` when the content type is `text/plain`.
  Printable strings will be passed through without hassle. ([#7](https://github.com/Cantido/liberator/issues/7))
- All responses now include an `allow` header, fixing the cases where one was required but not provided,
  like in an `OPTIONS` request, and when returning a 405 Method Not Allowed.
  ([#9](https://github.com/Cantido/liberator/issues/9), [#12](https://github.com/Cantido/liberator/issues/12))

## [1.3.0] - 2020-10-13

### Added
- The `:log` argument to the `:trace` option.
  Add a `trace: :log` option to your module's `use` statement,
  and every request will be logged with a trace.
  The log message even includes a request ID from `Plug.RequestId`, if you have one. ([#4](https://github.com/Cantido/liberator/issues/4))
- The `:decision_tree_overrides` argument to `Liberator.Resource`.
  This is an advanced feature that lets users override parts of the decision tree that Liberator evaluates.
  Want to change the ordering of some decisions, or add new ones?
  This is the way! ([#5](https://github.com/Cantido/liberator/issues/5))
- The `:handler_status_overrides` argument to `Liberator.Resource`.
  This is an advanced feature that lets users override status codes associated with handlers.
  It's mostly useful for those wanting to implement their own new statuses that Liberator doesn't support.
- The `:action_followup_overrides` argument to `Liberator.Resource`.
  This is an advanced feature that lets users override the functions called immediately after actions.
  It's mostly useful for those wanting to implement their own new actions that Liberator doesn't support.

## [1.2.0] - 2020-10-12

### Added
- The `402 Payment Required` status,
  along with related callbacks `payment_required?` and
  `handle_payment_required/1`.
- The `451 Unavailable for Legal Reasons` status,
  along with related callbacks `unavailable_for_legal_reasons?/1` and
  `handle_unavailable_for_legal_reasons/1`.
- The `429 Too Many Requests` status,
  along with related callbacks `too_many_requests?/1` and
  `handle_too_many_requests/1`.
  If you return a map containing a `:retry_after` value,
  Liberator will use that to set a `retry-after` header.
- You can also return a `:retry_after` value from any other decision function,
  like `service_available?/1`, or `moved_permanently?/1`, for the same effect.
  See [MDN's docs on the `retry-after` header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After)
  for more information on why you'd want to do this.

### Fixed
- Dates in headers are now parsed properly. ([#1](https://github.com/Cantido/liberator/issues/1))

## [1.1.0] - 2020-10-04

### Added
- This changelog!
- The `:trace` option:
  Add `trace: :headers` to your `use Liberator.Resource` statement to
  get an `x-liberator-trace` header added to responses,
  and see the result of all decisions.
- Compression options: `deflate`, `gzip`, and `identity`.

## Changed
- Codecs are now configurable.
  Set the `:media_types` and `:encodings` map in Liberator's config to add your own codecs.

### Removed
- `Liberator.Resource` no longer calls `use Timex`, so your context is less polluted.

## Fixed
- Better wildcard handling during content negotiation
- Content negotiation actually obeys q-values for priority

## [1.0.0] - 2020-10-02

### Added

- Basic decision tree navigation


[Unreleased]: https://github.com/Cantido/liberator/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/Cantido/liberator/releases/tag/v1.3.0
[1.2.0]: https://github.com/Cantido/liberator/releases/tag/v1.2.0
[1.1.0]: https://github.com/Cantido/liberator/releases/tag/v1.1.0
[1.0.0]: https://github.com/Cantido/liberator/releases/tag/v1.0.0
