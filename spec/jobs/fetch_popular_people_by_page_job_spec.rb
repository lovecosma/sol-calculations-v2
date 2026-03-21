# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchPopularPeopleByPageJob, type: :job do
  let(:api) { instance_double(CelebrityCharts::Api) }

  let(:person) { { "id" => 1, "original_name" => "Marie Curie", "profile_path" => "/abc.jpg" } }
  let(:details) { { "id" => 1, "birthday" => "1867-11-07", "original_name" => "Marie Curie", "profile_path" => "/abc.jpg" } }
  let(:popular_response) { { "results" => [ person ] } }

  before do
    allow(CelebrityCharts::Api).to receive(:new).and_return(api)
    allow(api).to receive(:fetch_popular_people).and_return(popular_response)
    allow(api).to receive(:fetch_person_details).and_return(details)
    allow(CelebrityCharts::Creator).to receive(:run)
  end

  describe "#perform" do
    it "fetches popular people for the given page" do
      expect(api).to receive(:fetch_popular_people).with(2)
      described_class.perform_now(2)
    end

    it "defaults to page 1" do
      expect(api).to receive(:fetch_popular_people).with(1)
      described_class.perform_now
    end

    it "fetches details for each person" do
      expect(api).to receive(:fetch_person_details).with(person["id"])
      described_class.perform_now
    end

    context "when fetch_person_details raises TmdbError" do
      before do
        allow(api).to receive(:fetch_person_details)
          .and_raise(CelebrityCharts::Api::TmdbError, "503 Service Unavailable")
      end

      it "skips the person and does not call Creator" do
        expect(CelebrityCharts::Creator).not_to receive(:run)
        expect { described_class.perform_now }.not_to raise_error
      end

      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with(/Skipping person #{person["id"]}/)
        described_class.perform_now
      end
    end

    context "when fetch_popular_people raises TmdbError" do
      before do
        allow(api).to receive(:fetch_popular_people)
          .and_raise(CelebrityCharts::Api::TmdbError, "500 Internal Server Error")
      end

      it "does not call Creator" do
        expect(CelebrityCharts::Creator).not_to receive(:run)
        described_class.perform_now rescue nil
      end
    end
  end

  describe "job configuration" do
    before { ActiveJob::Base.queue_adapter = :test }

    it "enqueues on the default queue" do
      expect {
        described_class.perform_later(1)
      }.to have_enqueued_job(described_class).with(1).on_queue("default")
    end

    it "is configured to retry on TmdbError" do
      retried_exceptions = described_class.rescue_handlers.map(&:first)
      expect(retried_exceptions).to include("CelebrityCharts::Api::TmdbError")
    end
  end
end
