require 'rails_helper'

RSpec.describe NumerologyNumbers::Descriptions::Builder do
  let(:number) { create(:number, value: 1) }
  let(:number_type) { create(:number_type) }
  let(:numerology_number) { create(:numerology_number, number: number, number_type: number_type) }
  let(:builder) { described_class.new(numerology_number: numerology_number) }

  describe '#run' do
    context 'valid response' do
      let(:valid_response_data) do
        {
          'primary_title' => 'The Leader',
          'secondary_titles' => [ 'The Pioneer', 'The Initiator', 'The Trailblazer' ],
          'thumbnail_description' => 'A natural leader with strong independence and initiative.',
          'core_essence' => [ 'Natural leadership', 'Independent thinking', 'Strong will' ],
          'strengths' => %w[Confident Innovative Courageous Determined],
          'challenges' => [ 'Impatient', 'Stubborn', 'Overly competitive' ],
          'matches' => %w[3 5 7],
          'mismatches' => %w[2 4 8],
          'description' => 'This number embodies leadership and independence.'
        }
      end

      before do
        allow(::GenClient::Base).to receive(:run).and_return(valid_response_data)
      end

      it 'successfully generates and saves description' do
        builder.run

        expect(numerology_number).to have_attributes(valid_response_data)
      end

      it 'calls GenClient::Base with correct parameters' do
        builder.run
        expect(::GenClient::Base).to have_received(:run)
      end
    end

    context 'with API errors' do
      before do
        allow(::GenClient::Base).to receive(:run).and_raise(
          ::GenClient::Base::OpenAIError.new('API request failed: API error')
        )
      end

      it 'raises OpenAIError' do
        expect { builder.run }.to raise_error(
          ::GenClient::Base::OpenAIError,
          /API request failed/
        )
      end
    end

    context 'with empty response' do
      before do
        allow(::GenClient::Base).to receive(:run).and_raise(
          ::GenClient::Base::OpenAIError.new('Empty response from OpenAI API')
        )
      end

      it 'raises OpenAIError for blank response' do
        expect { builder.run }.to raise_error(
          ::GenClient::Base::OpenAIError,
          /Empty response from OpenAI API/
        )
      end
    end

    context 'with invalid JSON response' do
      before do
        allow(::GenClient::Base).to receive(:run).and_raise(
          ::GenClient::Base::OpenAIError.new('Invalid JSON response')
        )
      end

      it 'raises OpenAIError for invalid JSON' do
        expect { builder.run }.to raise_error(
          ::GenClient::Base::OpenAIError,
          /Invalid JSON response/
        )
      end
    end

    context 'with null parsed response' do
      before do
        allow(::GenClient::Base).to receive(:run).and_return(nil)
      end

      it 'returns early without updating' do
        expect(numerology_number).not_to receive(:update)

        result = builder.run
        expect(result).to be_nil
      end
    end
  end
end
