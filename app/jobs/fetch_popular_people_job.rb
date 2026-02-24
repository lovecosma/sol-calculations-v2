# frozen_string_literal: true

class FetchPopularPeopleJob < ApplicationJob
  queue_as :default

  retry_on CelebrityCharts::Api::TmdbError,
           wait: :exponentially_longer,
           attempts: 5

  def perform(limit:)
    api = CelebrityCharts::Api.new
    total_pages = api.fetch_popular_people(1)["total_pages"]
    pages = [limit, total_pages].min

    (1..pages).each do |page|
      FetchPopularPeopleByPageJob.perform_later(page)
    end
  end
end
