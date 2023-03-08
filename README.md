# ActiveJob::Trackable

[![Gem Version](https://badge.fury.io/rb/activejob-trackable2.svg)](https://badge.fury.io/rb/activejob-trackable2)
[![CircleCI](https://circleci.com/gh/ignatiusreza/activejob-trackable.svg?style=svg)](https://circleci.com/gh/akatsuki-kk/active-job-trackable2)
[![Maintainability](https://api.codeclimate.com/v1/badges/e47b0b2c2e97a9034100/maintainability)](https://codeclimate.com/github/akatsuki-kk/active-job-trackable2/maintainability)

`include ActiveJob::Trackable` into any jobs you want to track. Tracking jobs will grant you
access into the lifetime of each jobs and give you the ability to throttle and debounce similar jobs.

This is useful for cases where you want to make sure that certain jobs are only done at most once
per certain period or when you want to reschedule/reconfigure previously scheduled jobs

## Usage

This gem is build with composition over inheritance in mind, and so to benefit from it
you can start by adding `include ActiveJob::Trackable` into any jobs you want to track, e.g.

```ruby
class SampleJob < ApplicationJob
  include ActiveJob::Trackable2

  trackable debounced: true, throttled: 1.day

  def perform(one, two, three); end
end
```

Calling `trackable` configures the trackers behavior, which defaulted to doing nothing.
Using this, you can tell the trackers to either `:debounced`, `:throttled`, or both.

`ActiveJob::Trackable::Debounced` and `ActiveJob::Trackable::Throttled` is also available as syntactic sugar

## Compatibility

For now, this gem only support `delayed_job` with `activerecord` backend,
but support for other delayed job backend and other queue adapters are desired.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'activejob-trackable'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install activejob-trackable2
```

run the generator:

```ruby
rails generate active_job:trackable
```

and run the generated migration:

```ruby
rake db:migrate
```

## Contributing

Any and all kind of help are welcomed! Especially interested in:

- support for other delayed job backend
- support for other queue adapters officially supported by `activejob` itself

feel free to file an issue/PR!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
