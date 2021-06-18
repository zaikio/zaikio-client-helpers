# Zaikio::Client::Helpers

A small gem which includes helpers for parsing & pagination when working with
Zaikio APIs using the [Spyke] library. Parts of this are referenced in:

  * [Zaikio Hub Client]
  * [Zaikio Procurement Client]

[Spyke]: https://github.com/balvig/spyke
[Zaikio Hub Client]: https://github.com/zaikio/zaikio-hub-ruby
[Zaikio Procurement Client]: https://github.com/zaikio/zaikio-procurement-ruby

## Installation

1. Add to your gemspec or Gemfile:

```ruby
spec.add_dependency "zaikio-client-helpers"
```

2. Require it when your code is loaded:

```ruby
require "zaikio-client-helpers"
```

## Parsing API responses

Spyke needs a couple of extra things in addition to JSON parsing, so this library exposes
a Spyke-compatible JSON parser that raises the correct exceptions when things go wrong:

```ruby
Faraday.new do |f|
  f.use Zaikio::Client::Helpers::JSONParser
  ...
end
```

> Note: if you're also using the pagination middleware below, you should set this
> middleware _after_ the pagination middleware, because it needs to run before pagination
> can happen.

## Automatic pagination

First, we need to configure the Faraday middleware, wherever the Faraday::Connection is
constructed:

```ruby
Faraday.new do |f|
  f.use Zaikio::Client::Helpers::Pagination::FaradayMiddleware
  f.use Zaikio::Client::Helpers::JSONParser
  ...
end
```

Then, in our classes which use pagination, we need to add this Spyke module:

```ruby
class Model < Spyke::Base
  include Zaikio::Client::Helpers::Pagination::Spyke
end
```

> It is also safe to include this module just in your base class for all models to share.

The module works by overriding the `#all` method on a relation, so it will keep fetching
pages from the remote API until there are none left:

```ruby
Model.all.map(&:id)
#=> There are 3 pages, I will load more pages automatically
#=> [1,2,3]
```

If you wish to opt-out of automatic pagination, you can use the Lazy version (don't forget
to call `each` or `to_a` to materialize the records):

```ruby
Model.all.lazy.take(2).map(&:id).to_a
```
