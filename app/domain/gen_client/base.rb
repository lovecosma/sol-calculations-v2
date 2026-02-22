# frozen_string_literal: true
require "bundler/setup"
require "openai"
require "json"

module GenClient
  class Base
    class OpenAIError < StandardError; end

    include Command
    option :system_content, optional: true
    option :user_content
    option :response_structure, optional: true
    option :model, default: -> { "gpt-5-nano" }

    def run
      parsed_response
    end

    private

    def client
      @client ||= ::OpenAI::Client.new(
        api_key: ENV["OPEN_AI_SECRET_KEY"]
      )
    end

    def messages
      [
        system_message,
        user_message
      ].compact
    end

    def system_message
      return nil unless system_content

      { role: :system, content: system_content }
    end

    def user_message
      { role: :user, content: user_content }
    end

    def response
      request_params = {
        model: model,
        input: messages
      }

      # Add response structure if provided
      request_params[:text] = response_structure if response_structure

      client.responses.create(**request_params)
    rescue StandardError => e
      Rails.logger.error("OpenAI API error: #{e.class} - #{e.message}")
      raise OpenAIError, "API request failed: #{e.message}"
    end

    def parsed_response
      return @parsed_response if defined?(@parsed_response)

      text = response_text

      if text.blank?
        Rails.logger.error("Empty response from OpenAI")
        raise OpenAIError, "Empty response from OpenAI API"
      end

      @parsed_response = JSON.parse(text)
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse OpenAI response: #{e.message}")
      Rails.logger.error("Response text: #{text}")
      raise OpenAIError, "Invalid JSON response: #{e.message}"
    end

    def response_text
      api_response = response
      text = api_response&.output&.last&.content&.first&.text

      unless text
        raise OpenAIError, "Invalid response structure from OpenAI API"
      end

      text
    end
  end
end
