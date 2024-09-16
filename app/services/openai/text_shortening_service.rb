# frozen_string_literal: true

require "faraday"
require "json"

class TextShorteningService
  OPENAI_API_URL = "https://api.openai.com/v1/chat/completions"
  API_KEY = "YourKey"

  def initialize
    @connection = Faraday.new(url: OPENAI_API_URL) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def shorten_text(text, characters_limit)
    conversation_history = build_initial_user_message(text, characters_limit)
    response = openai_chat(conversation_history, characters_limit)
    conversation_history << response.body["choices"][0]["message"] if response.success?
    content = parse_response(response, characters_limit)

    if response.success? && content.length > characters_limit
      return retry_shortening(conversation_history, characters_limit, content)
    end

    content
  rescue StandardError
    text
  end

  private

  def build_initial_user_message(text, characters_limit)
    [
      {
        role: "user",
        content: "Please shorten the below title to a maximum of #{characters_limit} characters,
                  including spaces and special characters. Verify that the response meets the
                  character limit before replying. Also make sure to only reply with the
                  abbreviation. #{text}"
      }
    ]
  end

  def openai_chat(conversation_history, _characters_limit)
    @connection.post do |req|
      req.headers["Authorization"] = "Bearer #{API_KEY}"
      req.body = {
        model: "gpt-4",
        messages: conversation_history,
        temperature: 0,
        n: 1,
        stop: "\n"
      }.to_json
    end
  end

  def parse_response(response, _characters_limit)
    raise response.body["error"]["message"] unless response.success?

    response.body["choices"][0]["message"]["content"].strip.gsub(/^['"]|['"]$/, "")
  end

  def retry_shortening(conversation_history, characters_limit, content)
    5.times do
      ap "Retrying for the previous result: #{content}"
      break if content.length <= characters_limit

      new_prompt = prepare_new_prompt(content, characters_limit)
      conversation_history << new_prompt

      response = openai_chat(conversation_history, characters_limit)
      conversation_history << response.body["choices"][0]["message"] if response.success?
      content = parse_response(response, characters_limit)
    end

    content
  end

  def prepare_new_prompt(_content, characters_limit)
    {
      role: "user",
      content: "This is more than #{characters_limit} characters. Please make another iteration
                and make sure to stay below the character limit. Also make sure to only reply
                with the abbreviation as before."
    }
  end
end
