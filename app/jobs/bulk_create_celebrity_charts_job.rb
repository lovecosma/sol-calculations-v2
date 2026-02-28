# frozen_string_literal: true

class BulkCreateCelebrityChartsJob < ApplicationJob
  queue_as :default

  def perform(external_ids)
    Celebrity.where(external_id: external_ids, celebrity_chart_id: nil).pluck(:id).each do |celebrity_id|
      CreateCelebrityChartJob.perform_later(celebrity_id)
    end
  end
end
