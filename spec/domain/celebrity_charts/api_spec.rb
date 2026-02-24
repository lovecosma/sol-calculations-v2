# frozen_string_literal: true

require "rails_helper"

RSpec.describe CelebrityCharts::Api do
  subject(:api) { described_class.new }

  let(:api_key) { "test_api_key" }
  let(:response_body) { { "results" => [], "page" => 1, "total_pages" => 1 }.to_json }
  let(:http) { instance_double(Net::HTTP) }
  let(:success_response) { double("success_response", body: response_body) }

  before do
    allow(ENV).to receive(:fetch).with("TMDB_API_KEY").and_return(api_key)
    allow(Net::HTTP).to receive(:start).with("api.themoviedb.org", 443, use_ssl: true).and_yield(http)
    allow(http).to receive(:request).and_return(success_response)
    allow(success_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
  end

  describe "#fetch_popular_people" do
    it "returns parsed JSON" do
      expect(api.fetch_popular_people).to eq(JSON.parse(response_body))
    end

    it "hits the /person/popular endpoint" do
      expect(http).to receive(:request) do |req|
        expect(req.path).to include("/person/popular")
        success_response
      end
      api.fetch_popular_people
    end

    it "defaults to page 1" do
      expect(http).to receive(:request) do |req|
        expect(req.path).to include("page=1")
        success_response
      end
      api.fetch_popular_people
    end

    it "passes the given page number" do
      expect(http).to receive(:request) do |req|
        expect(req.path).to include("page=3")
        success_response
      end
      api.fetch_popular_people(3)
    end

    it "sends the default language" do
      expect(http).to receive(:request) do |req|
        expect(req.path).to include("language=en-US")
        success_response
      end
      api.fetch_popular_people
    end

    it "sends the Bearer authorization header" do
      expect(http).to receive(:request) do |req|
        expect(req["Authorization"]).to eq("Bearer #{api_key}")
        success_response
      end
      api.fetch_popular_people
    end

    it "sets the Accept header to application/json" do
      expect(http).to receive(:request) do |req|
        expect(req["Accept"]).to eq("application/json")
        success_response
      end
      api.fetch_popular_people
    end
  end

  describe "#fetch_person_details" do
    let(:person_id) { 456 }

    it "returns parsed JSON" do
      expect(api.fetch_person_details(person_id)).to eq(JSON.parse(response_body))
    end

    it "hits the /person/:id endpoint" do
      expect(http).to receive(:request) do |req|
        expect(req.path).to include("/person/#{person_id}")
        success_response
      end
      api.fetch_person_details(person_id)
    end

    it "sends the default language" do
      expect(http).to receive(:request) do |req|
        expect(req.path).to include("language=en-US")
        success_response
      end
      api.fetch_person_details(person_id)
    end

    it "sends the Bearer authorization header" do
      expect(http).to receive(:request) do |req|
        expect(req["Authorization"]).to eq("Bearer #{api_key}")
        success_response
      end
      api.fetch_person_details(person_id)
    end
  end

  describe "language option" do
    subject(:api) { described_class.new(language: "fr-FR") }

    it "uses the custom language for fetch_popular_people" do
      expect(http).to receive(:request) do |req|
        expect(req.path).to include("language=fr-FR")
        success_response
      end
      api.fetch_popular_people
    end

    it "uses the custom language for fetch_person_details" do
      expect(http).to receive(:request) do |req|
        expect(req.path).to include("language=fr-FR")
        success_response
      end
      api.fetch_person_details(1)
    end
  end

  describe "error handling" do
    let(:error_response) { double("error_response", code: "401", message: "Unauthorized") }

    before do
      allow(http).to receive(:request).and_return(error_response)
      allow(error_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
    end

    it "raises TmdbError with status details on a failed fetch_popular_people" do
      expect { api.fetch_popular_people }
        .to raise_error(CelebrityCharts::Api::TmdbError, /401.*Unauthorized/)
    end

    it "raises TmdbError with status details on a failed fetch_person_details" do
      expect { api.fetch_person_details(1) }
        .to raise_error(CelebrityCharts::Api::TmdbError, /401.*Unauthorized/)
    end

    context "with a 500 error" do
      let(:error_response) { double("error_response", code: "500", message: "Internal Server Error") }

      it "raises TmdbError" do
        expect { api.fetch_popular_people }
          .to raise_error(CelebrityCharts::Api::TmdbError, /500.*Internal Server Error/)
      end
    end
  end
end
