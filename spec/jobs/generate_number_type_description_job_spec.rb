require 'rails_helper'

RSpec.describe GenerateNumberTypeDescriptionJob, type: :job do
  let(:number_type) { create(:number_type) }

  before do
    allow(NumberTypes::Descriptions::Builder).to receive(:run)
  end

  describe '#perform' do
    it 'finds the number type and calls the builder' do
      described_class.perform_now(number_type.id)
      expect(NumberTypes::Descriptions::Builder).to have_received(:run)
        .with(number_type: number_type)
    end

    context 'when description and thumbnail_description are already present' do
      before do
        number_type.update_columns(description: "A description", thumbnail_description: "A summary")
      end

      it 'does not call the builder' do
        described_class.perform_now(number_type.id)
        expect(NumberTypes::Descriptions::Builder).not_to have_received(:run)
      end
    end

    context 'with an OpenAI error' do
      it 'is configured to retry on OpenAIError' do
        retried_exceptions = described_class.rescue_handlers.map(&:first)
        expect(retried_exceptions).to include('GenClient::Base::OpenAIError')
      end
    end

    context 'when the number type does not exist' do
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
        described_class.perform_later(number_type.id)
      }.to have_enqueued_job(described_class)
        .with(number_type.id)
        .on_queue('default')
    end
  end
end
