require 'httparty'

class Somleng::TwilioHttpClient::Client
  # From: https://www.twilio.com/docs/api/errors/11200
  DEFAULT_TIMEOUT = 15

  attr_accessor :logger,
                :last_request_url,
                :timeout

  def initialize(options = {})
    self.logger = options[:logger]
    self.timeout = options[:timeout]
  end

  def execute!(request_method, request_url, request_options)
    log(
      :info, "Executing HTTP #{request_method.to_s.upcase} request to '#{request_url}' with the following options: #{request_options}"
    )

    self.last_request_url = request_url
    HTTParty.send(request_method, request_url, default_request_options.merge(request_options))
  end

  def timeout
    @timeout ||= ENV["SOMLENG_TWILIO_HTTP_CLIENT_TIMEOUT"] || DEFAULT_TIMEOUT
  end

  private

  def default_request_options
    {
      :timeout => timeout
    }
  end

  def log(*args)
    logger && logger.public_send(*args)
  end
end
