# Rate limit control

Take control of the rate limit of your actions. This gem is primarily designed to work with Redis, but you can adapt other key-value databases to work with it. It was inspired by this [post](https://medium.com/@pebneter/fast-and-simple-rate-limiting-with-ruby-on-rails-and-redis-68e76ba38ca4).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rate_limit_control'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rate_limit_control

## Usage

Define the configurations of your actions:

```
action_config = {
  action: 'rate_limit_example',
  id: 'foobar',
  allowed_requests: 5,
  storage: Redis.new,
  timeout: 30,
}
```

You need to set your action as a block inside the rate limit control.
```
RateLimitControl::Create.call!(action_config) do
  puts "This action will be suspended after the 5th execution"
end
```

After the 5th execution, the next action will be blocked until the timeout ends up. All actions with the same configuration will be blocked during this time.

## Action params

* **action**: Action name;
* **id**: Id of the action, the same action could be executed by different requesters;
* **allowed_requests**: Number of requests allow to be executed during the timeout period;
* **storage**: Key-value database instance;
* **timeout**: Time in seconds to unblock actions;

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/boniattirodrigo/rate_limit_control. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RateLimitControl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/boniattirodrigo/rate_limit_control/blob/master/CODE_OF_CONDUCT.md).
