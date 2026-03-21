# frozen_string_literal: true

require "bundler/setup"
require "openai"
require "json"

module NumberTypes
  module Descriptions
    class Builder
      include Command
      option :number_type

      def run
        Rails.logger.info("Generating description for number_type #{number_type.id}")

        response_data = GenClient::Base.run(
          system_content: system_content,
          user_content: user_content,
          response_structure: NumberTypeDescription
        )
        return unless response_data

        number_type.update(response_data)
      end

      private

      def system_content
        "You are a professional numerologist and expert in numerology. Your descriptions are concise, clear, and insightful."
      end

      def user_content
        <<~CONTENT
          You are an expert numerologist with the clarity of a school teacher.
          Provide an in-depth description of the #{NumberType::HUMAN_NAMES[number_type.name]} number type in numerology.

          Your task is to explain what this number type reveals about a person and why it matters.

          Write in a tone that is:
          - Empowering and spiritually insightful
          - Direct but uplifting
          - Nurturing
          - Less poetic, more supportive

          For the #{NumberType::HUMAN_NAMES[number_type.name]} number type, provide:

          1. description — 5 paragraphs of in-depth detail covering: what this number type is and how it is calculated, what it reveals about a person's core nature, its role in a full numerology reading, how it manifests in real life, and its spiritual or higher significance.
          2. thumbnail_description — A summary of 100 to 200 words capturing the essence of this number type and why it matters in a numerology reading.
        CONTENT
      end
    end
  end
end
