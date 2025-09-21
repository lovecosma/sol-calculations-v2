# frozen_string_literal: true
require "bundler/setup"
require "openai"
module Descriptions
class Fetcher

extend Dry::Initializer

option :numerology_number

def run
openai = OpenAI::Client.new(
	api_key: ENV["OPEN_AI_SECRET_KEY"]
)
chat_completion = openai.chat.completions.create(messages: [{role: "user", content:}], model: :"gpt-5-nano")

description = chat_completion.choices.first.message.content
Description.create(context: 'general', short: description, numerology_number: numerology_number)
end

def content
<<~CONTENT
        In five sentences, provide a concise and insightful numerology reading for a #{NumberType::HUMAN_NAMES[numerology_number.name]} #{numerology_number.value}.
				Focus on its core attributes, strengths, and potential challenges.
				Ensure the tone is professional and clear, avoiding any mystical or overly complex language.
			  The reading should be accessible to someone new to numerology while still offering depth for those familiar with the subject.
      CONTENT
end
end
end
