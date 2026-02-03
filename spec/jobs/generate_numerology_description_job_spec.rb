require 'rails_helper'

RSpec.describe GenerateNumerologyDescriptionJob, type: :job do
  let(:numerology_number) { create(:numerology_number) }

  before do
    allow(NumerologyNumbers::Descriptions::Builder).to receive(:run)
  end

  describe '#perform' do
    it 'calls the builder with correct arguments' do
      described_class.perform_now(numerology_number)
      expect(NumerologyNumbers::Descriptions::Builder).to have_received(:run)
        .with(numerology_number: numerology_number)
    end

    context 'with errors' do
      before do
        allow(NumerologyNumbers::Descriptions::Builder).to receive(:run)
          .and_raise(StandardError.new('Unexpected error'))
      end

      it 'does not catch errors' do
        expect {
          described_class.perform_now(numerology_number)
        }.to raise_error(StandardError, 'Unexpected error')
      end
    end
  end

  describe 'job configuration' do
    it 'enqueues the job with correct arguments' do
      expect {
        described_class.perform_later(numerology_number)
      }.to have_enqueued_job(described_class)
        .with(numerology_number)
        .on_queue('default')
    end
  end
end
