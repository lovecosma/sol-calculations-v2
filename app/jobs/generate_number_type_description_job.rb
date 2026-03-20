# frozen_string_literal: true

class GenerateNumberTypeDescriptionJob < ApplicationJob
  queue_as :default

  retry_on GenClient::Base::OpenAIError,
           wait: :exponentially_longer,
           attempts: 5

  def perform(number_type_id)
    number_type = NumberType.find(number_type_id)
    return if number_type.description.present? && number_type.thumbnail_description.present?

    Rails.logger.info("Starting AI description generation job for number_type #{number_type.id}")
    NumberTypes::Descriptions::Builder.run(number_type: number_type)
    Rails.logger.info("Completed AI description generation job for number_type #{number_type.id}")
  end
end
