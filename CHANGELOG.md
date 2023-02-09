## [Unreleased]

- Add a default read timeout for Faraday connection of 5 seconds, and open timeout of 1 second.

## [0.3.0] - 2022-08-15

- Add `Zaikio::Client::Helpers::AuthorizationMiddleware` and `Zaikio::Client.with_token` to pass down bearer token to multiple clients (e.g. hub + procurement) at the same time
- Add `Zaikio::Client::Helpers::Configuration` as an abstract configuration class
- Add `Zaikio::Client.create_connection`

## [0.2.4] - 2022-03-29

- Add support for Faraday 2.x

## [0.2.3] - 2021-11-12

- Handle "uncountable" responses (i.e. those without a Total-Count or Total-Pages header)

## [0.2.2] - 2021-08-12

- Attempt to fix `NoMethodError` when looking for pagination headers

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
