# frozen_string_literal: true

class FetchPopularPeopleByPageJob < ApplicationJob
  queue_as :default

  retry_on CelebrityCharts::Api::TmdbError,
           wait: :exponentially_longer,
           attempts: 5

  def perform(page = 1)
    api         = CelebrityCharts::Api.new
    valid_attrs = CelebrityCharts::PeopleFetcher.run(api: api, page: page)

    return if valid_attrs.empty?

    Celebrity.upsert_all(
      valid_attrs,
      unique_by: :external_id,
      update_only: %i(original_name birthdate profile_path popularity)
    )
  end
end
