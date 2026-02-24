# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchPopularPeopleJob, type: :job do
  let(:api) { instance_double(CelebrityCharts::Api) }

  before do
    allow(CelebrityCharts::Api).to receive(:new).and_return(api)
    allow(api).to receive(:fetch_popular_people).and_return({ "total_pages" => 10 })
    ActiveJob::Base.queue_adapter = :test
  end

  describe "#perform" do
    it "fetches page 1 to determine total_pages" do
      expect(api).to receive(:fetch_popular_people).with(1).and_return({ "total_pages" => 3 })
      described_class.perform_now(limit: 3)
    end

    it "enqueues a FetchPopularPeopleByPageJob for each page up to the limit" do
      described_class.perform_now(limit: 3)
      expect(FetchPopularPeopleByPageJob).to have_been_enqueued.with(1)
      expect(FetchPopularPeopleByPageJob).to have_been_enqueued.with(2)
      expect(FetchPopularPeopleByPageJob).to have_been_enqueued.with(3)
    end

    it "enqueues exactly limit jobs when limit is less than total_pages" do
      expect {
        described_class.perform_now(limit: 3)
      }.to have_enqueued_job(FetchPopularPeopleByPageJob).exactly(3).times
    end

    it "caps at total_pages when limit exceeds total_pages" do
      allow(api).to receive(:fetch_popular_people).and_return({ "total_pages" => 2 })
      expect {
        described_class.perform_now(limit: 100)
      }.to have_enqueued_job(FetchPopularPeopleByPageJob).exactly(2).times
    end

    it "enqueues no jobs when total_pages is 0" do
      allow(api).to receive(:fetch_popular_people).and_return({ "total_pages" => 0 })
      expect {
        described_class.perform_now(limit: 5)
      }.not_to have_enqueued_job(FetchPopularPeopleByPageJob)
    end

    context "when the API raises TmdbError" do
      before do
        allow(api).to receive(:fetch_popular_people)
          .and_raise(CelebrityCharts::Api::TmdbError, "503 Service Unavailable")
      end

      it "does not enqueue any page jobs" do
        expect {
          described_class.perform_now(limit: 5) rescue nil
        }.not_to have_enqueued_job(FetchPopularPeopleByPageJob)
      end
    end
  end

  describe "job configuration" do
    it "enqueues on the default queue" do
      expect {
        described_class.perform_later(limit: 5)
      }.to have_enqueued_job(described_class).with(limit: 5).on_queue("default")
    end

    it "is configured to retry on TmdbError" do
      retried_exceptions = described_class.rescue_handlers.map(&:first)
      expect(retried_exceptions).to include("CelebrityCharts::Api::TmdbError")
    end
  end
end
