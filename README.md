# Somleng::TwilioHttpClient

[![Build Status](https://travis-ci.org/somleng/somleng-twilio_http_client.svg?branch=master)](https://travis-ci.org/somleng/somleng-twilio_http_client)
[![Test Coverage](https://codeclimate.com/github/somleng/somleng-twilio_http_client/badges/coverage.svg)](https://codeclimate.com/github/somleng/somleng-twilio_http_client/coverage)
[![Code Climate](https://codeclimate.com/github/somleng/somleng-twilio_http_client/badges/gpa.svg)](https://codeclimate.com/github/somleng/somleng-twilio_http_client)

[Somleng::TwilioHttpClient](https://github.com/somleng/somleng-twilio_http_client) is an Open Source implementation of [Twilio's HTTP Client](https://www.twilio.com/docs/api/twiml/twilio_request). The client is used in [Twilreapi](https://github.com/somleng/twilreapi) (An Open Source Implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest)) as well as in [Adhearsion-Twilio](https://github.com/somleng/adhearsion-twilio) (An [Adhearsion](https://github.com/adhearsion/adhearsion) plugin which interprets [TwiML](https://www.twilio.com/docs/api/twiml)).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'somleng-twilio_http_client'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install somleng-twilio_http_client
```

## Usage

```
  $ ./bin/console
```

```ruby
  require 'somleng/twilio_http_client/request'
  request = Somleng::TwilioHttpClient::Request.new
  request.request_url = "https://hookb.in/E7Rgk2lP"
  request.request_method = "POST"
  request.auth_token = "some-auth-token"
  response = request.execute!
  response.body
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/somleng/somleng-twilio_http_client.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
