# frozen_string_literal: true

class EnqueueCelebrityChartCreationJob < ApplicationJob
  queue_as :default

  def perform
    Celebrity.where(celebrity_chart_id: nil).find_each do |celebrity|
      CreateCelebrityChartJob.perform_later(celebrity.id)
    end
  end
end
