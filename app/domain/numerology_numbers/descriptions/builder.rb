# frozen_string_literal: true
require "bundler/setup"
require "openai"
require "json"

module NumerologyNumbers
  module Descriptions
    class Builder
      class NumerologyNumberDescription < OpenAI::BaseModel
        required :primary_title, String
        required :secondary_titles, OpenAI::ArrayOf[String]
        required :thumbnail_description, String
        required :core_essence, OpenAI::ArrayOf[String]
        required :strengths, OpenAI::ArrayOf[String]
        required :challenges, OpenAI::ArrayOf[String]
        required :matches, OpenAI::ArrayOf[Integer]
        required :mismatches, OpenAI::ArrayOf[Integer]
        required :description, String
      end

      include Command
      extend Dry::Initializer
      option :numerology_number

      # Custom error class for better error tracking
      class OpenAIError < StandardError; end

      MAX_RETRIES = 3
      RETRY_DELAY = 2 # seconds
      REQUEST_TIMEOUT = 30 # seconds

      def run
        response_data = fetch_description_with_retry
        return unless response_data

        numerology_number.update(response_data)
      rescue OpenAIError => e
        Rails.logger.error("OpenAI API error for numerology_number #{numerology_number.id}: #{e.message}")
        # Re-raise so caller can handle or queue for retry
        raise
      rescue StandardError => e
        Rails.logger.error("Unexpected error generating description for numerology_number #{numerology_number.id}: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace.first(5).join("\n"))
        raise
      end

      private

      def fetch_description_with_retry
        retries = 0
        begin
          parsed_response
        rescue JSON::ParserError, OpenAI::Error => e
          retries += 1
          if retries <= MAX_RETRIES
            Rails.logger.warn("Retry #{retries}/#{MAX_RETRIES} for numerology_number #{numerology_number.id} after error: #{e.message}")
            sleep(RETRY_DELAY * retries) # Exponential backoff
            retry
          else
            raise OpenAIError, "Failed after #{MAX_RETRIES} retries: #{e.message}"
          end
        end
      end

      def client
        @client ||= OpenAI::Client.new(
          api_key: ENV["OPEN_AI_SECRET_KEY"],
          request_timeout: REQUEST_TIMEOUT
        )
      end

      def content
        <<~CONTENT
          You are an expert numerologist with the clarity of a school teacher.
          Provide a concise and insightful numerology reading for a #{NumberType::HUMAN_NAMES[numerology_number.name]} #{numerology_number.value}.

          Your task is to generate archetypal, emotionally compelling descriptions of this number’s energetic signature.

          Write in a tone that is:
          - Empowering and spiritually insightful
          - Direct but uplifting
          - Nurturing
          - Less poetic, more supportive

          For the given number, provide content for the following fields:

          1. primary_title — One powerful archetype name that defines this number's highest expression (e.g., "The Leader", "The Builder", "The Visionary").
          2. secondary_titles — 2 to 4 alternate archetypes that reflect different facets of this number  (e.g., "The Leader", "The Builder", "The Visionary").
          3. thumbnail_description — One concise sentence that summarizes this number's key strengths and weaknesses in a balanced way.
          4. core_essence — 2 to 4 short poetic statements summarizing its core personality, purpose, or soul frequency.
          5. strengths — 3 to 5 statements of its greatest capabilities, gifts, or virtues.
          6. challenges — 3 to 5 statements of its most common struggles, lessons, or pitfalls.
          7. matches — An array of number values that naturally support or complement this number.
          8. mismatches — An array of number values that often conflict with or challenge this number.
          9. description — A 150 to 200 word narrative weaving together the above elements into a basic description of this numerology number.
        CONTENT
      end

      def response
        Rails.logger.info("Requesting OpenAI description for numerology_number #{numerology_number.id} (#{numerology_number.number_type.name} #{numerology_number.number.value})")

        client.responses.create(
          model: "gpt-5-nano",
          input: [
            { role: :system, content: "You are professional numerologist and expert in numerology. Your descriptions are concise, clear, and insightful." },
            { role: :user, content: content }
          ],
          text: NumerologyNumberDescription
        )
      rescue OpenAI::Error => e
        raise OpenAIError, "OpenAI API request failed: #{e.message}"
      rescue StandardError => e
        raise OpenAIError, "Unexpected error during API request: #{e.class} - #{e.message}"
      end

      def parsed_response
        return @parsed_response if defined?(@parsed_response)

        text = response_text

        if text.blank?
          Rails.logger.error("Empty response from OpenAI for numerology_number #{numerology_number.id}")
          raise OpenAIError, "Empty response from OpenAI API"
        end

        @parsed_response = JSON.parse(text)
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse OpenAI response for numerology_number #{numerology_number.id}: #{e.message}")
        Rails.logger.error("Response text: #{text}")
        raise
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
end