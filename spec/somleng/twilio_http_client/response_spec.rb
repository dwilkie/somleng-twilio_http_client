require 'spec_helper'
require 'somleng/twilio_http_client/response'
require 'httparty'

RSpec.describe Somleng::TwilioHttpClient::Response do
  let(:body) { "body" }
  let(:raw_response) { instance_double(HTTParty::Response, :body => body) }

  subject {
    described_class.new(raw_response)
  }

  describe "#body" do
    def assert_body!
      expect(subject.body).to eq(body)
    end

    it { assert_body! }
  end
end
