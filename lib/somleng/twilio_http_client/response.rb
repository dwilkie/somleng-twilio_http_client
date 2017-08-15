class Somleng::TwilioHttpClient::Response
  attr_reader :raw_response

  def initialize(raw_response)
    @raw_response = raw_response
  end

  def body
    raw_response.body
  end
end
