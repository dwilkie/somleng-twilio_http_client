require 'spec_helper'
require 'somleng/twilio_http_client/util/url'

RSpec.describe Somleng::TwilioHttpClient::Util::Url do
  subject {
    described_class.new(url)
  }

  describe "#extract_auth" do
    let(:url) { "https://#{http_basic_credentials}somleng.org/api/foo_bar" }
    let(:result) { subject.extract_auth }
    let(:authorization) { result[0] }
    let(:sanitized_url) { result[1] }

    context "url has http basic user and password embedded" do
      let(:http_basic_user) { "user" }
      let(:http_basic_password) { "password" }
      let(:http_basic_credentials) { "#{http_basic_user}:#{http_basic_password}@" }

      def assert_result!
        expect(authorization[:username]).to eq(http_basic_user)
        expect(authorization[:password]).to eq(http_basic_password)
        expect(sanitized_url).to eq(url.sub(http_basic_credentials, ""))
      end

      it { assert_result! }
    end

    context "url has no auth embedded" do
      let(:http_basic_credentials) { nil }

      def assert_result!
        expect(authorization).to eq({})
        expect(sanitized_url).to eq(url)
      end

      it { assert_result! }
    end
  end
end
