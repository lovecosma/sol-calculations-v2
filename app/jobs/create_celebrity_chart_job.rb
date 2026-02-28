# frozen_string_literal: true

class CreateCelebrityChartJob < ApplicationJob
  queue_as :default

  def perform(celebrity_id)
    celebrity = Celebrity.find(celebrity_id)
    CelebrityCharts::Creator.run(celebrity: celebrity)
  end
end
