# frozen_string_literal: true

module CelebrityCharts
  class PeopleFetcher
    include Command

    option :api
    option :page, default: -> { 1 }

    def run
      data = api.fetch_popular_people(page)

      data["results"].filter_map do |person|
        details   = api.fetch_person_details(person["id"])
        attrs     = person.merge(details).slice("original_name", "birthday", "profile_path", "popularity")
        birthdate = attrs["birthday"].presence && Date.parse(attrs["birthday"])

        next unless CelebrityChart.new(full_name: attrs["original_name"], birthdate: birthdate).valid?

        {
          external_id:   person["id"],
          original_name: attrs["original_name"],
          birthdate:     birthdate,
          profile_path:  attrs["profile_path"],
          popularity:    attrs["popularity"],
          created_at:    Time.current,
          updated_at:    Time.current
        }
      rescue CelebrityCharts::Api::TmdbError => e
        Rails.logger.warn("Skipping person #{person["id"]}: #{e.message}")
        nil
      end
    end
  end
end
