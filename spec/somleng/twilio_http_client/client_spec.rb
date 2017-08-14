require 'spec_helper'
require 'somleng/twilio_http_client/client'

RSpec.describe Somleng::TwilioHttpClient::Client do
  # From: http://www.twilio.com/docs/api/twiml/twilio_request

  # Twilio makes HTTP requests to your application just like a regular web browser.
  # By including parameters and values in its requests,
  # Twilio sends data to your application that you can act upon before responding.
  # You can configure the URLs and HTTP Methods Twilio uses to make its requests
  # via the account portal or using the REST API.

  # Creating a Twilio Application within your account will allow you to more-easily
  # configure the URLs you want Twilio to request when receiving a voice call to one
  # of your phone numbers. Instead of assigning URLs directly to a phone number,
  # you can assign them to an application and then assign that application to the
  # phone number. This will allow you to pass around configuration between phone numbers
  # without having to memorize or copy and paste URLs.

  def setup_scenario
    WebMock.clear_requests!
    stub_request(asserted_request_method, asserted_request_url)
  end

  before do
    setup_scenario
  end

  let(:request_url) { "https://voice-request.com/twiml.xml" }
  let(:request_method) { "POST" }
  let(:asserted_request_url) { request_url }
  let(:asserted_request_method) { request_method.to_s.downcase.to_sym }
  let(:call_from) { "+85512345678" }
  let(:call_to) { "+85512345679" }
  let(:call_sid) { "abcdefg" }
  let(:account_sid) { "AC938112122121" }
  let(:call_direction) { nil }
  let(:auth_token) { "some_auth_token" }
  let(:call_status) { nil }

  subject {
    described_class.new(
      :request_url => request_url,
      :request_method => request_method,
      :call_sid => call_sid,
      :account_sid => account_sid,
      :call_from => call_from,
      :call_to => call_to,
      :call_direction => call_direction,
      :auth_token => auth_token,
      :call_status => call_status
    )
  }

  let(:http_request_params) { WebMock.request_params(http_request) }
  let(:http_request) { WebMock.requests.last }

  describe "#execute_request!(options = {})" do
    # From: http://www.twilio.com/docs/api/twiml/twilio_request

    # adhearsion-twilio configuration:
    # config.twilio.voice_request_url
    # config.twilio.voice_request_method

    # When Twilio receives a call for one of your Twilio numbers it makes a synchronous
    # HTTP request to the Voice URL configured for that number, and expects to receive
    # TwiML in response. Twilio sends the following parameters with its request as POST
    # parameters or URL query parameters, depending on which HTTP method you've configured:

    # Request Parameters

    # | Parameter     | Description                                                              |
    # |               |                                                                          |
    # | CallSid       | A unique identifier for this call, generated by Twilio.                  |
    # |               |                                                                          |
    # | AccountSid    | Your Twilio account id. It is 34 characters long,                        |
    # |               | and always starts with the letters AC.                                   |
    # |               |                                                                          |
    # | From          | The phone number or client identifier of the party                       |
    # |               | that initiated the call. Phone numbers are formatted                     |
    # |               | with a '+' and country code, e.g. +16175551212 (E.164 format).           |
    # |               | Client identifiers begin with the client: URI scheme; for example,       |
    # |               | for a call from a client named 'tommy', the From parameter               |
    # |               | will be client:tommy.                                                    |
    # |               |                                                                          |
    # | To            | The phone number or client identifier of the called party.               |
    # |               | Phone numbers are formatted with a '+' and country code,                 |
    # |               | e.g. +16175551212 (E.164 format). Client identifiers begin with          |
    # |               | the client: URI scheme; for example, for a call to a client named        |
    # |               |                                                                          |
    # |               | 'jenny', the To parameter will be client:jenny.                          |
    # | CallStatus    | A descriptive status for the call. The value is one of queued,           |
    # |               | ringing, in-progress, completed, busy, failed or no-answer.              |
    # |               | See the CallStatus section below for more details.                       |
    # |               |                                                                          |
    # | ApiVersion    | The version of the Twilio API used to handle this call.                  |
    # |               | For incoming calls, this is determined by the API version                |
    # |               | set on the called number. For outgoing calls, this is the                |
    # |               | API version used by the outgoing call's REST API request.                |
    # |               |                                                                          |
    # | Direction     | Indicates the direction of the call. In most cases this will be inbound, |
    # |               | but if you are using <Dial> it will be outbound-dial.                    |
    # |               |                                                                          |
    # | ForwardedFrom | This parameter is set only when Twilio receives a forwarded call,        |
    # |               | but its value depends on the caller's carrier including information      |
    # |               | when forwarding. Not all carriers support passing this information.      |
    # |               |                                                                          |
    # | CallerName    | This parameter is set when the IncomingPhoneNumber that received         |
    # |               | the call has had its VoiceCallerIdLookup value set to true               |
    # |               | ($0.01 per look up).                                                     |

    # Twilio also attempts to look up geographic data based on the 'To' and 'From'
    # phone numbers. The following parameters are sent, if available:

    # | Parameter   | Description                                |
    # | FromCity    | The city of the caller.                    |
    # | FromState   | The state or province of the caller.       |
    # | FromZip     | The postal code of the caller.             |
    # | FromCountry | The country of the caller.                 |
    # | ToCity      | The city of the called party.              |
    # | ToState     | The state or province of the called party. |
    # | ToZip       | The postal code of the called party.       |
    # | ToCountry   | The country of the called party.           |

    # Depending on the what is happening on a call, other variables may also be sent.
    # The individual TwiML verb sections have more details.

    # CallStatus Values

    # The following are the possible values for the 'CallStatus' parameter.
    # These values also apply to the 'DialCallStatus' parameter,
    # which is sent with requests to a <Dial> Verb's action URL.

    # | Status      | Description
    # | queued      | The call is ready and waiting in line before going out.         |
    # | ringing     | The call is currently ringing.                                  |
    # | in-progress | The call was answered and is currently in progress.             |
    # | completed   | The call was answered and has ended normally.                   |
    # | busy        | The caller received a busy signal.                              |
    # | failed      | The call could not be completed as dialed,                      |
    # |             | most likely because the phone number was non-existent.          |
    # | no-answer   | The call ended without being answered.                          |
    # | canceled    | The call was canceled via the REST API while queued or ringing. |

    def setup_scenario
      super
      do_execute_request!
    end

    def do_execute_request!
      execute_request!
    end

    def execute_request_options
      {}
    end

    def execute_request!
      subject.execute_request!(execute_request_options)
    end

    let(:actual_call_status) { http_request_params["CallStatus"] }

    context "invalid request method specified" do
      let(:request_method) { "HEAD" }

      def do_execute_request!
      end

      it { expect { execute_request! }.to raise_error(RuntimeError, /#{described_class::VALID_REQUEST_METHODS}/) }
    end

    context "overrides" do
      let(:overridden_request_url) { "https://overridden.com/test.xml" }
      let(:overridden_request_method) { "GET" }

      def execute_request_options
        super.merge(
          :request_url => overridden_request_url,
          :request_method => overridden_request_method,
          :call_status => :busy
        )
      end

      let(:asserted_request_url) { overridden_request_url }
      let(:asserted_request_method) { overridden_request_method.downcase.to_sym }

      def assert_request!
        expect(http_request.method).to eq(asserted_request_method)
        expect(actual_call_status).to eq("busy")
        expect(subject.request_url).to eq(request_url)
        expect(subject.request_method).to eq(request_method.downcase)
        expect(subject.last_request_url).to eq(overridden_request_url)
      end

      it { assert_request! }
    end

    context "CallStatus" do
      def assert_request!
        expect(actual_call_status).to eq(asserted_call_status)
      end

      context "by default" do
        let(:asserted_call_status) { "ringing" }
        it { assert_request! }
      end

      context "is :in_progress" do
        let(:call_status) { :in_progress }
        let(:asserted_call_status) { "in-progress" }

        it { assert_request! }
      end
    end

    context "Authorization Header" do
      context "without HTTP Basic Auth specified in the URL" do
        let(:request_url) { "https://voice-request.com:1234/twiml.xml" }

        def assert_request!
          expect(http_request.headers).not_to have_key("Authorization")
        end

        it { assert_request! }
      end

      context "with HTTP Basic Auth specified in the URL" do
        let(:request_url) { "https://user:password@voice-request.com:1234/twiml.xml" }
        let(:asserted_request_url) { "https://voice-request.com:1234/twiml.xml" }

        def assert_request!
          authorization = Base64.decode64(http_request.headers["Authorization"].sub(/^Basic\s/, ""))
          user, password = authorization.split(":")
          expect(user).to eq("user")
          expect(password).to eq("password")
        end

        it { assert_request! }
      end
    end

    context "HTTP method" do
      def assert_request!
        expect(http_request.method).to eq(asserted_http_method)
      end

      context "POST" do
        let(:request_method) { "POST" }
        let(:asserted_http_method) { :post }

        it { assert_request! }
      end

      context "GET" do
        let(:request_method) { "GET" }
        let(:asserted_http_method) { :get }

        it { assert_request! }
      end
    end

    context "Request Signature" do
      let(:request_validator) { Somleng::TwilioHttpClient::Util::RequestValidator.new(auth_token) }
      let(:request_signature) { http_request.headers["X-Twilio-Signature"] }
      let(:auth_token) { "my_auth_token" }

      def assert_request!
        expect(
          request_validator.validate(
            request_url, http_request_params, request_signature
          )
        ).to eq(true)
      end

      it { assert_request! }
    end

    context "Direction" do
      def assert_request!
        expect(http_request_params["Direction"]).to eq(asserted_direction)
      end

      context "for inbound calls" do
        let(:asserted_direction) { "inbound" }
        it { assert_request! }
      end

      context "for outbound calls" do
        let(:call_direction) { :outbound_api }
        let(:asserted_direction) { "outbound-api" }
        it { assert_request! }
      end
    end

    context "HTTP Body" do
      def assert_request!
        expect(http_request_params["ApiVersion"]).to eq("somleng-twilio_http_client-#{Somleng::TwilioHttpClient::VERSION}")
        expect(http_request_params).to have_key("CallStatus")
        expect(http_request_params).to have_key("Direction")
        expect(http_request_params).to have_key("ApiVersion")
        expect(http_request_params["From"]).to eq(call_from)
        expect(http_request_params["To"]).to eq(call_to)
        expect(http_request_params["CallSid"]).to eq(call_sid)
        if account_sid
          expect(http_request_params["AccountSid"]).to eq(account_sid)
        else
          expect(http_request_params).not_to have_key("AccountSid")
        end
      end

      it { assert_request! }

      context "no account sid" do
        let(:account_sid) { nil }
        it { assert_request! }
      end
    end
  end
end
