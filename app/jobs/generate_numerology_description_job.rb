# frozen_string_literal: true

class GenerateNumerologyDescriptionJob < ApplicationJob
  queue_as :default

  retry_on NumerologyNumbers::Descriptions::Builder::OpenAIError,
           wait: :exponentially_longer,
           attempts: 5
  
  def perform(numerology_number)
    Rails.logger.info("Starting AI description generation job for numerology_number #{numerology_number.id}")

    NumerologyNumbers::Descriptions::Builder.run(numerology_number: numerology_number)

    Rails.logger.info("Completed AI description generation job for numerology_number #{numerology_number.id}")
  end
end
