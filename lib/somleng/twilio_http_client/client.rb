require 'httparty'

require_relative "util/url"
require_relative "util/request_validator"

class Somleng::TwilioHttpClient::Client
  CALL_STATUSES = {
    :no_answer => "no-answer",
    :answer => "completed",
    :timeout => "no-answer",
    :error => "failed",
    :busy  => "busy",
    :in_progress => "in-progress",
    :ringing => "ringing"
  }

  CALL_DIRECTIONS = {
    :inbound => "inbound",
    :outbound_api => "outbound-api"
  }

  DEFAULT_REQUEST_METHOD = "post"

  VALID_REQUEST_METHODS = [
    DEFAULT_REQUEST_METHOD, "get"
  ]

  DEFAULT_CALL_STATUS = :ringing

  attr_accessor :request_url,
                :request_method,
                :account_sid,
                :call_sid,
                :call_direction,
                :call_from,
                :call_to,
                :auth_token,
                :call_status,
                :logger,
                :last_request_url

  def initialize(options = {})
    self.request_url = options[:request_url]
    self.request_method = options[:request_method]
    self.account_sid = options[:account_sid]
    self.call_from = options[:call_from]
    self.call_to = options[:call_to]
    self.call_sid = options[:call_sid]
    self.call_direction = options[:call_direction]
    self.auth_token = options[:auth_token]
    self.call_status = options[:call_status]
    self.logger = options[:logger]
  end

  def execute_request!(options = {})
    request_url = options[:request_url] || self.request_url
    request_method = sanitize_request_method(options[:request_method] || self.request_method)
    call_status = options[:call_status] || self.call_status

    basic_auth, sanitized_request_url = extract_auth(request_url)
    self.last_request_url = sanitized_request_url

    validate_request_method!

    request_body = {
      "CallStatus" => CALL_STATUSES[call_status],
    }.merge(build_request_body)

    headers = build_twilio_signature_header(sanitized_request_url, request_body)

    request_options = {
      :body => request_body,
      :headers => headers
    }

    request_options.merge!(:basic_auth => basic_auth) if basic_auth.any?

    log(:info, "Notifying HTTP with method: #{request_method}, URL: #{sanitized_request_url} and options: #{request_options}")

    HTTParty.send(
      request_method,
      sanitized_request_url,
      request_options
    ).body
  end

  def request_method
    sanitize_request_method(@request_method || DEFAULT_REQUEST_METHOD)
  end

  def call_status
    @call_status || DEFAULT_CALL_STATUS
  end

  private

  def sanitize_request_method(value)
    value.to_s.downcase
  end

  def validate_request_method!
    raise(
      "#request_method must be one of either: #{VALID_REQUEST_METHODS}"
    ) if !VALID_REQUEST_METHODS.include?(request_method)
  end

  def log(*args)
    logger && logger.public_send(*args)
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

  def api_version
    "somleng-twilio_http_client-#{Somleng::TwilioHttpClient::VERSION}"
  end

  def twilio_call_direction
    CALL_DIRECTIONS[(call_direction || :inbound).to_sym]
  end

  def build_request_body
    request_options = {
      "From" => call_from,
      "To" => call_to,
      "CallSid" => call_sid,
      "Direction" => twilio_call_direction,
      "ApiVersion" => api_version
    }

    request_options.merge!("AccountSid" => account_sid) if account_sid
    request_options
  end
end
