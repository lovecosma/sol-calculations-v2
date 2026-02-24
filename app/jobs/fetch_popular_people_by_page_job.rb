# frozen_string_literal: true

class FetchPopularPeopleByPageJob < ApplicationJob
  queue_as :default

  retry_on CelebrityCharts::Api::TmdbError,
           wait: :exponentially_longer,
           attempts: 5

  def perform(page = 1)
    api  = CelebrityCharts::Api.new
    data = api.fetch_popular_people(page)

    data["results"].each do |person|
      details = api.fetch_person_details(person["id"])
      sliced_data = person.merge(details).slice("birthday", "original_name", "profile_path")
      CelebrityCharts::Creator.run(celebrity_data: sliced_data)
    rescue CelebrityCharts::Api::TmdbError => e
      Rails.logger.warn("Skipping person #{person["id"]}: #{e.message}")
    end
  end
end
