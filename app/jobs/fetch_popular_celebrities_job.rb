# frozen_string_literal: true

class FetchPopularCelebritiesJob < ApplicationJob
  queue_as :default

  def perform
    api  = CelebrityCharts::Api.new
    data = api.fetch_popular_people(1)

    (1..data["total_pages"]).each do |page|
      FetchPopularPeopleByPageJob.perform_later(page)
    end
  end
end
