require 'spec_helper'
require 'somleng/twilio_http_client/client'

RSpec.describe Somleng::TwilioHttpClient::Client do
  describe "#execute!(request_method, request_url, request_options)" do
    let(:request_method) { :post }
    let(:request_url) { "http://www.somleng.org/some-url.xml" }
    let(:request_options) { {} }
    let(:response) { subject.execute!(request_method, request_url, request_options) }

    let(:http_request) { WebMock.requests.last }

    def setup_scenario
      stub_request(request_method, request_url)
      response
    end

    before do
      setup_scenario
    end

    def assert_execute!
      expect(WebMock).to have_requested(request_method, request_url)
      expect(subject.last_request_url).to eq(request_url)
    end

    it { assert_execute! }
  end
end
