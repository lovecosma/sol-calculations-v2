# frozen_string_literal: true
require "bundler/setup"
require "openai"

module NumerologyNumbers
  module Descriptions
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
  end
end
