# frozen_string_literal: true

require "bundler/setup"
require "openai"

module NumberTypes
  module Descriptions
    class NumberTypeDescription < OpenAI::BaseModel
      required :description, String
      required :thumbnail_description, String
    end
  end
end
