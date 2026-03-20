require 'rails_helper'

RSpec.describe NumberTypes::Descriptions::Builder do
  let(:number_type) { create(:number_type) }
  let(:builder) { described_class.new(number_type: number_type) }

  describe '#run' do
    context 'valid response' do
      let(:valid_response_data) do
        {
          'description' => 'The Life Path number is the most significant number in your numerology chart.',
          'thumbnail_description' => 'Reveals your life purpose and the path you are meant to walk.'
        }
      end

      before do
        allow(::GenClient::Base).to receive(:run).and_return(valid_response_data)
      end

      it 'saves the generated description to the number type' do
        builder.run
        expect(number_type).to have_attributes(valid_response_data)
      end

      it 'calls GenClient::Base with the correct parameters' do
        expect(::GenClient::Base).to receive(:run).with(
          system_content: builder.send(:system_content),
          user_content: builder.send(:user_content),
          response_structure: NumberTypes::Descriptions::NumberTypeDescription
        )
        builder.run
      end
    end

    context 'with a nil response' do
      before do
        allow(::GenClient::Base).to receive(:run).and_return(nil)
      end

      it 'returns early without updating' do
        expect(number_type).not_to receive(:update)
        expect(builder.run).to be_nil
      end
    end

    context 'with an API error' do
      before do
        allow(::GenClient::Base).to receive(:run).and_raise(
          ::GenClient::Base::OpenAIError.new('API request failed: API error')
        )
      end

      it 'raises OpenAIError' do
        expect { builder.run }.to raise_error(::GenClient::Base::OpenAIError, /API request failed/)
      end
    end
  end

  describe '#user_content' do
    it 'includes the human name of the number type' do
      expect(builder.send(:user_content)).to include(NumberType::HUMAN_NAMES[number_type.name])
    end
  end
end
