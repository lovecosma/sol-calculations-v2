# frozen_string_literal: true

class EnqueueCelebrityChartCreationJob < ApplicationJob
  queue_as :default

  def perform
    external_ids = Celebrity.where(celebrity_chart_id: nil).pluck(:external_id)
    BulkCreateCelebrityChartsJob.perform_later(external_ids) if external_ids.any?
  end
end
