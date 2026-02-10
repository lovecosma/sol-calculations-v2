require 'rails_helper'

RSpec.describe NumerologyNumbers::Descriptions::Builder do
  let(:number) { create(:number, value: 1) }
  let(:number_type) { create(:number_type) }
  let(:numerology_number) { create(:numerology_number, number: number, number_type: number_type) }
  let(:builder) { described_class.new(numerology_number: numerology_number) }
  let(:mock_client) { instance_double(OpenAI::Client) }

  describe '#run' do
    context 'valid response' do
      let(:valid_response_data) do
        {
          'primary_title' => 'The Leader',
          'secondary_titles' => ['The Pioneer', 'The Initiator', 'The Trailblazer'],
          'thumbnail_description' => 'A natural leader with strong independence and initiative.',
          'core_essence' => ['Natural leadership', 'Independent thinking', 'Strong will'],
          'strengths' => %w(Confident Innovative Courageous Determined),
          'challenges' => ['Impatient', 'Stubborn', 'Overly competitive'],
          'matches' => %w(3 5 7),
          'mismatches' => %w(2 4 8),
          'description' => 'This number embodies leadership and independence.'
        }
      end

      let(:mock_responses) { double('responses') }
      let(:mock_api_response) { double('api_response') }
      let(:mock_output) { double('output', content: [double('content', text: valid_response_data.to_json)]) }

      before do
        allow(builder).to receive(:client).and_return(mock_client)
        allow(mock_client).to receive(:responses).and_return(mock_responses)
        allow(mock_responses).to receive(:create).and_return(mock_api_response)
        allow(mock_api_response).to receive(:output).and_return([mock_output])
      end

      it 'successfully generates and saves description' do
        builder.run

        expect(numerology_number).to have_attributes(valid_response_data)
      end
    end

    context 'with API errors' do
      let(:mock_responses) { double('responses') }

      before do
        allow(builder).to receive(:client).and_return(mock_client)
        allow(mock_client).to receive(:responses).and_return(mock_responses)
        allow(mock_responses).to receive(:create).and_raise(StandardError.new('API error'))
      end

      it 'raises OpenAIError' do
        expect { builder.run }.to raise_error(
          NumerologyNumbers::Descriptions::Builder::OpenAIError,
          /API request failed/
        )
      end
    end

    context 'with empty response' do
      let(:mock_responses) { double('responses') }
      let(:mock_api_response) { double('api_response') }
      let(:mock_output) { double('output', content: [double('content', text: '')]) }

      before do
        allow(builder).to receive(:client).and_return(mock_client)
        allow(mock_client).to receive(:responses).and_return(mock_responses)
        allow(mock_responses).to receive(:create).and_return(mock_api_response)
        allow(mock_api_response).to receive(:output).and_return([mock_output])
      end

      it 'raises OpenAIError for blank response' do
        expect { builder.run }.to raise_error(
          NumerologyNumbers::Descriptions::Builder::OpenAIError,
          /Empty response from OpenAI API/
        )
      end
    end

    context 'with invalid JSON response' do
      let(:mock_responses) { double('responses') }
      let(:mock_api_response) { double('api_response') }
      let(:mock_output) { double('output', content: [double('content', text: 'invalid json {{{')]) }

      before do
        allow(builder).to receive(:client).and_return(mock_client)
        allow(mock_client).to receive(:responses).and_return(mock_responses)
        allow(mock_responses).to receive(:create).and_return(mock_api_response)
        allow(mock_api_response).to receive(:output).and_return([mock_output])
      end

      it 'raises OpenAIError for invalid JSON' do
        expect { builder.run }.to raise_error(
          NumerologyNumbers::Descriptions::Builder::OpenAIError,
          /Invalid JSON response/
        )
      end
    end

    context 'with invalid response structure' do
      let(:mock_responses) { double('responses') }
      let(:mock_api_response) { double('api_response') }

      before do
        allow(builder).to receive(:client).and_return(mock_client)
        allow(mock_client).to receive(:responses).and_return(mock_responses)
        allow(mock_responses).to receive(:create).and_return(mock_api_response)
      end

      context 'when output is nil' do
        before do
          allow(mock_api_response).to receive(:output).and_return(nil)
        end

        it 'raises OpenAIError' do
          expect { builder.run }.to raise_error(
            NumerologyNumbers::Descriptions::Builder::OpenAIError,
            /Invalid response structure from OpenAI API/
          )
        end
      end

      context 'when output is empty array' do
        before do
          allow(mock_api_response).to receive(:output).and_return([])
        end

        it 'raises OpenAIError' do
          expect { builder.run }.to raise_error(
            NumerologyNumbers::Descriptions::Builder::OpenAIError,
            /Invalid response structure from OpenAI API/
          )
        end
      end

      context 'when content is nil' do
        let(:mock_output) { double('output', content: nil) }

        before do
          allow(mock_api_response).to receive(:output).and_return([mock_output])
        end

        it 'raises OpenAIError' do
          expect { builder.run }.to raise_error(
            NumerologyNumbers::Descriptions::Builder::OpenAIError,
            /Invalid response structure from OpenAI API/
          )
        end
      end

      context 'when content is empty array' do
        let(:mock_output) { double('output', content: []) }

        before do
          allow(mock_api_response).to receive(:output).and_return([mock_output])
        end

        it 'raises OpenAIError' do
          expect { builder.run }.to raise_error(
            NumerologyNumbers::Descriptions::Builder::OpenAIError,
            /Invalid response structure from OpenAI API/
          )
        end
      end

      context 'when text is nil' do
        let(:mock_output) { double('output', content: [double('content', text: nil)]) }

        before do
          allow(mock_api_response).to receive(:output).and_return([mock_output])
        end

        it 'raises OpenAIError' do
          expect { builder.run }.to raise_error(
            NumerologyNumbers::Descriptions::Builder::OpenAIError,
            /Invalid response structure from OpenAI API/
          )
        end
      end
    end

    context 'with null parsed response' do
      let(:mock_responses) { double('responses') }
      let(:mock_api_response) { double('api_response') }
      let(:mock_output) { double('output', content: [double('content', text: 'null')]) }

      before do
        allow(builder).to receive(:client).and_return(mock_client)
        allow(mock_client).to receive(:responses).and_return(mock_responses)
        allow(mock_responses).to receive(:create).and_return(mock_api_response)
        allow(mock_api_response).to receive(:output).and_return([mock_output])
      end

      it 'returns early without updating' do
        expect(numerology_number).not_to receive(:update)

        result = builder.run
        expect(result).to be_nil
      end
    end
  end
end
