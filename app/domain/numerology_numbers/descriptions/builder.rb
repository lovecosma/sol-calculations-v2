# frozen_string_literal: true
require "bundler/setup"
require "openai"
require "json"

module NumerologyNumbers
  module Descriptions
    class Builder
      class NumerologyNumberDescription < OpenAI::BaseModel
        required :description, String
        required :primary_title, String
        required :secondary_titles, OpenAI::ArrayOf[String]
        required :core_essence, OpenAI::ArrayOf[String]
        required :strengths, OpenAI::ArrayOf[String]
        required :challenges, OpenAI::ArrayOf[String]
        required :matches, OpenAI::ArrayOf[Integer]
        required :mismatches, OpenAI::ArrayOf[Integer]
      end

      include Command
      extend Dry::Initializer
      option :numerology_number

      def run
        return if parsed_response.blank?
        numerology_number.update(parsed_response)
      end

      private

      def client
        @client ||= OpenAI::Client.new(api_key: ENV["OPEN_AI_SECRET_KEY"])
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

          1. primary_title — One powerful archetype name that defines this number’s highest expression (e.g., “The Leader”, “The Builder”, “The Visionary”).
          2. secondary_titles — 2 to 4 alternate archetypes that reflect different facets of this number  (e.g., “The Leader”, “The Builder”, “The Visionary”).
          3. core_essence — 2 to 4 short poetic statements summarizing its core personality, purpose, or soul frequency.
          4. strengths — 3 to 5 statements of its greatest capabilities, gifts, or virtues.
          5. challenges — 3 to 5 statements of its most common struggles, lessons, or pitfalls.
          6. matches — An array of number values that naturally support or complement this number.
          7. mismatches — An array of number values that often conflict with or challenge this number.
          8. description — A 150 to 200 word narrative weaving together the above elements into a basic description of this numerology number.
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
      end

      def parsed_response
        @parsed_response ||= JSON.parse(response_text) rescue {}
      end

      def response_text
        response&.output&.last&.content&.first&.text
      end
    end
  end
end