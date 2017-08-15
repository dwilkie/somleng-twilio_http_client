require_relative "client"
require_relative "response"
require_relative "util/url"
require_relative "util/request_validator"

class Somleng::TwilioHttpClient::Request
  VALID_REQUEST_METHODS = ["post", "get"]

  attr_accessor :client,
                :request_url,
                :request_method,
                :account_sid,
                :call_sid,
                :call_direction,
                :call_from,
                :call_to,
                :auth_token,
                :call_status,
                :api_version,
                :body

  def initialize(options = {})
    self.client = options[:client]
    self.request_url = options[:request_url]
    self.request_method = options[:request_method]
    self.account_sid = options[:account_sid]
    self.call_from = options[:call_from]
    self.call_to = options[:call_to]
    self.call_sid = options[:call_sid]
    self.call_direction = options[:call_direction]
    self.auth_token = options[:auth_token]
    self.call_status = options[:call_status]
    self.body = options[:body]
    self.api_version = options[:api_version]
  end

  def execute!
    basic_auth, sanitized_request_url = extract_auth(request_url)
    sanitized_request_method = sanitize_request_method(request_method)
    validate_request_method!(sanitized_request_method)

    request_body = default_request_body.merge(body)

    headers = build_twilio_signature_header(
      sanitized_request_url, request_body
    )

    request_options = {
      :body => request_body,
      :headers => headers
    }

    request_options.merge!(:basic_auth => basic_auth) if basic_auth.any?

    Somleng::TwilioHttpClient::Response.new(
      client.execute!(
        sanitized_request_method,
        sanitized_request_url,
        request_options
      )
    )
  end

  def body
    @body ||= {}
  end

  def client
    @client ||= Somleng::TwilioHttpClient::Client.new
  end

  private

  def sanitize_request_method(value)
    value.to_s.downcase
  end

  def validate_request_method!(request_method)
    raise(
      "#request_method must be one of either: #{VALID_REQUEST_METHODS}"
    ) if !VALID_REQUEST_METHODS.include?(request_method)
  end

  def build_twilio_signature_header(url, params)
    {"X-Twilio-Signature" => twilio_request_validator.build_signature_for(url, params)}
  end

  def twilio_request_validator
    @twilio_request_validator ||= Somleng::TwilioHttpClient::Util::RequestValidator.new(auth_token)
  end

  def extract_auth(url)
    Somleng::TwilioHttpClient::Util::Url.new(url).extract_auth
  end

  def default_request_body
    request_options = {}
    request_options.merge!("From" => call_from) if call_from
    request_options.merge!("To" => call_to) if call_to
    request_options.merge!("CallSid" => call_sid) if call_sid
    request_options.merge!("CallStatus" => call_status) if call_status
    request_options.merge!("Direction" => call_direction) if call_direction
    request_options.merge!("AccountSid" => account_sid) if account_sid
    request_options.merge!("ApiVersion" => api_version) if api_version
    request_options
  end
end
