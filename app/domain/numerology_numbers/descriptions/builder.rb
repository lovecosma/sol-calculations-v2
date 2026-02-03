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
      option :numerology_number

      class OpenAIError < StandardError; end

      def run
        Rails.logger.info("Generating description for numerology_number #{numerology_number.id}")

        response_data = parsed_response
        return unless response_data

        numerology_number.update(response_data)
      end

      private

      def client
        @client ||= OpenAI::Client.new(
          api_key: ENV["OPEN_AI_SECRET_KEY"]
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
        client.responses.create(
          model: "gpt-5-nano",
          input: [
            { role: :system, content: "You are professional numerologist and expert in numerology. Your descriptions are concise, clear, and insightful." },
            { role: :user, content: content }
          ],
          text: NumerologyNumberDescription
        )
      rescue StandardError => e
        Rails.logger.error("API error for numerology_number #{numerology_number.id}: #{e.class} - #{e.message}")
        raise OpenAIError, "API request failed: #{e.message}"
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
end