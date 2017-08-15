require 'httparty'

class Somleng::TwilioHttpClient::Client
  attr_accessor :logger, :last_request_url

  def initialize(options = {})
    self.logger = options[:logger]
  end

  def execute!(request_method, request_url, request_options)
    log(
      :info, "Executing HTTP #{request_method.to_s.upcase} request to '#{request_url}' with the following options: #{request_options}"
    )

    self.last_request_url = request_url
    HTTParty.send(request_method, request_url, request_options)
  end

  private

  def log(*args)
    logger && logger.public_send(*args)
  end
end
