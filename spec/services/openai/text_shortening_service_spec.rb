# spec/services/openai/text_shortening_service_spec.rb
require "rails_helper"
require "faraday"
require "json"

RSpec.describe Openai::TextShorteningService, type: :service do
  let(:service) { described_class.new }
  let(:text) { "This is a long title that needs to be shortened" }
  let(:characters_limit) { 30 }
  let(:shortened_text) { "Shortened title" }

  before do
    allow(service).to receive(:openai_chat).and_return(response)
  end

  let(:response) do
    instance_double(Faraday::Response, success?: true, body: {
                      "choices" => [
                        {
                          "message" => { "content" => shortened_text }
                        }
                      ]
                    })
  end

  describe "#shorten_text" do
    context "when the API returns a successful response within the character limit" do
      it "returns the shortened text" do
        result = service.shorten_text(text, characters_limit)

        expect(result).to eq(shortened_text)
      end
    end
  end

  context "when the initial response exceeds the character limit" do
    let(:long_text) { "A very long response that exceeds the character limit." }
    let(:retry_response) do
      instance_double(Faraday::Response, success?: true, body: {
                        "choices" => [
                          {
                            "message" => { "content" => "Shorter version" }
                          }
                        ]
                      })
    end

    before do
      allow(service).to receive(:openai_chat).and_return(
        instance_double(Faraday::Response, success?: true,
                                           body: { "choices" =>
                                           [{ "message" => { "content" => long_text } }] }),
        retry_response
      )
    end

    it "retries the shortening and returns the final shortened version" do
      result = service.shorten_text(text, characters_limit)

      expect(result).to eq("Shorter version")
      expect(service).to have_received(:openai_chat).twice
    end
  end

  context "when the API response is not successful" do
    let(:error_response) do
      instance_double(Faraday::Response, success?: false,
                                         body: { "error" => { "message" => "Something went wrong" } })
    end

    before do
      allow(service).to receive(:openai_chat).and_return(error_response)
    end

    it "raises an error and returns the original text" do
      result = service.shorten_text(text, characters_limit)

      expect(result).to eq(text)
    end
  end

  context "when the text exceeds the character limit even after retries" do
    let(:long_text) { "This is a very long text that cannot be shortened below the limit." }

    before do
      allow(service).to receive(:openai_chat).and_return(
        instance_double(Faraday::Response, success?: true,
                                           body: { "choices" => [{ "message" => { "content" => long_text } }] })
      )
    end

    it "returns the final attempted text after retries" do
      result = service.shorten_text(text, characters_limit)

      expect(result).to eq(long_text)
    end
  end

  context "when a StandardError occurs" do
    before do
      allow(service).to receive(:openai_chat).and_raise(StandardError)
    end

    it "returns the original text when an error occurs" do
      result = service.shorten_text(text, characters_limit)

      expect(result).to eq(text) # Returns the original text on error
    end
  end

  describe "#build_initial_user_message" do
    it "constructs the correct prompt with the text and character limit" do
      message = service.send(:build_initial_user_message, text, characters_limit)

      expect(message.first[:content]).to include("Please shorten the below title")
      expect(message.first[:content]).to include("maximum of #{characters_limit} characters")
      expect(message.first[:content]).to include(text)
    end
  end
end
