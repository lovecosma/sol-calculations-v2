# frozen_string_literal: true

require "net/http"
require "json"

module CelebrityCharts
  class Api
    extend Dry::Initializer

    class TmdbError < StandardError; end

    BASE_URL = "https://api.themoviedb.org/3"

    option :language,optional: true, default: -> { "en-US" }

    def fetch_popular_people(page = 1)
      uri = URI("#{BASE_URL}/person/popular")
      uri.query = URI.encode_www_form(page: page, language: language)
      parse!(get(uri))
    end

    def fetch_person_details(person_id)
      uri = URI("#{BASE_URL}/person/#{person_id}")
      uri.query = URI.encode_www_form(language: language)
      parse!(get(uri))
    end

    private

    def get(uri)
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = authorization_header
      request["Accept"] = "application/json"

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def parse!(response)
      unless response.is_a?(Net::HTTPSuccess)
        raise TmdbError, "TMDB API error: #{response.code} #{response.message}"
      end

      JSON.parse(response.body)
    end

    def authorization_header
      @authorization_header ||= "Bearer #{ENV.fetch("TMDB_API_KEY")}"
    end
  end
end
