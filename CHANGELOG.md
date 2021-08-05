## [Unreleased]

## [0.2.1] - 2021-08-05

- Fixed `with_fallback` from spyke by aliasing the correct error classes

## [0.2.0] - 2021-07-22

- Add `Zaikio:Error` and allow setting arbitrary attributes on the exceptions
- Add `Zaikio::RateLimitedError` when HTTP 429 occurs (note that this subclasses
  `Zaikio::ConnectionError` so all existing error handling should continue to work).

## [0.1.1] - 2021-06-18

- Require `zaikio/client/model` as part of gem loading to avoid need to load it elsewhere
- Fix message about total number of pages - count pages, not objects!

## [0.1.0] - 2021-06-17

- Initial release
