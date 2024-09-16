class ChatCompletion < ApplicationService
  attr_reader :input_message, :characters_limit

  def initialize(input_message, characters_limit)
    @input_message = input_message
    @characters_limit = characters_limit
  end

  def call
    shorten_text(input_message, characters_limit)
  end

  def shorten_text(prompt, characters_limit)
    Rails.logger.info "Calling ChatGPT API with prompt: #{prompt}"

    user_messages = build_user_messages(prompt, characters_limit)
    conversation_history = user_messages

    response = openai_chat(conversation_history, characters_limit)
    content = parse_response(response, characters_limit)
    
    if content.length > characters_limit
      Rails.logger.info "Result exceeds #{characters_limit} characters, retrying..."
      retry_shortening(conversation_history, characters_limit)
    else
      content
    end
  rescue StandardError => e
    Rails.logger.error "Error: #{e.message}"
    raise
  end

  private

  def build_user_messages(prompt, characters_limit)
    [
      {
        role: "system",
        content: "Please shorten the given German medical title to a maximum of #{characters_limit} characters. 
                  Verify the response meets the limit before replying."
      },
      {
        role: "user",
        content: "Shorten this text to #{characters_limit} characters or less: '#{prompt}'"
      }
    ]
  end

  def openai_chat(conversation_history, characters_limit)
    @connection.post do |req|
      req.headers['Authorization'] = "Bearer #{ENV['API_KEY']}"
      req.body = {
        model: "gpt-4", 
        messages: conversation_history,
        max_tokens: characters_limit,
        temperature: 0,
        n: 1,
        stop: "\n"
      }.to_json
    end
  end

  def parse_response(response, characters_limit)
    if response.success?
      response.body['choices'][0]['message']['content'].strip.gsub(/'(.*?)'/, '\1')
    else
      raise response.body['error']['message']
    end
  end

  def retry_shortening(conversation_history, characters_limit)
    iterative_message = {
      role: "user",
      content: "This is more than #{characters_limit} characters. Please shorten it again."
    }
    conversation_history << iterative_message
    response = openai_chat(conversation_history, characters_limit)
    parse_response(response, characters_limit)
  end

  def connection
    @connection = Faraday.new(url: ENV['OPENAI_API_URL']) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end
end