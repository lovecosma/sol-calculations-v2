# frozen_string_literal: true
require "bundler/setup"
require "openai"
require "json"

module NumerologyNumbers
  module Descriptions
    class Builder
      include Command
      option :numerology_number

      def run
        Rails.logger.info("Generating description for numerology_number #{numerology_number.id}")

        response_data = GenClient::Base.run(
          system_content: system_content,
          user_content: user_content,
          response_structure: NumerologyNumberDescription
        )
        return unless response_data

        numerology_number.update(response_data)
      end

      private

      def system_content
        "You are professional numerologist and expert in numerology. Your descriptions are concise, clear, and insightful."
      end

      def user_content
        <<~CONTENT
          You are an expert numerologist with the clarity of a school teacher.
          Provide a concise and insightful numerology reading for a #{NumberType::HUMAN_NAMES[numerology_number.name]} #{numerology_number.value}.

          Your task is to generate archetypal, emotionally compelling descriptions of this number's energetic signature.

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
    end
  end
end