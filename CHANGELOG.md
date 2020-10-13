# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- The `451 Unavailable for Legal Reasons` status.
  Implement the callbacks `unavailable_for_legal_reasons?/1` and
  `handle_unavailable_for_legal_reasons/1` to see it work.
- The `429 Too Many Requests` status.
  Implement the callbacks `too_many_requests?/1` and
  `handle_too_many_requests/1` to see it work.
  If you return a map containing a `:retry_after` value,
  Liberator will use that to set a `retry-after` header.

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


[Unreleased]: https://github.com/Cantido/liberator/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/Cantido/liberator/releases/tag/v1.1.0
[1.0.0]: https://github.com/Cantido/liberator/releases/tag/v1.0.0