require 'rails_helper'

RSpec.describe GenerateNumerologyDescriptionJob, type: :job do
  let(:numerology_number) { create(:numerology_number) }

  before do
    allow(NumerologyNumbers::Descriptions::Builder).to receive(:run)
  end

  describe '#perform' do
    it 'finds the numerology number and calls the builder' do
      described_class.perform_now(numerology_number.id)
      expect(NumerologyNumbers::Descriptions::Builder).to have_received(:run)
        .with(numerology_number: numerology_number)
    end

    context 'with an OpenAI error' do
      it 'is configured to retry on OpenAIError' do
        retried_exceptions = described_class.rescue_handlers.map(&:first)
        expect(retried_exceptions).to include('GenClient::Base::OpenAIError')
      end
    end

    context 'when the numerology number does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.perform_now(-1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'job configuration' do
    it 'enqueues on the default queue with the ID' do
      expect {
        described_class.perform_later(numerology_number.id)
      }.to have_enqueued_job(described_class)
        .with(numerology_number.id)
        .on_queue('default')
    end
  end
end
