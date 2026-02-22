require 'rails_helper'

RSpec.describe GenClient::Base do
  let(:system_content) { "You are a helpful assistant." }
  let(:user_content) { "What is the meaning of life?" }
  let(:mock_openai_client) { instance_double(::OpenAI::Client) }
  let(:mock_responses) { double('responses') }

    describe '#run' do
      context 'with valid response' do
        let(:response_data) { { "answer" => "42" } }
        let(:mock_api_response) { double('api_response') }
        let(:mock_output) { double('output', content: [double('content', text: response_data.to_json)]) }
        let(:client) do
          described_class.new(
            system_content: system_content,
            user_content: user_content
          )
        end
  
        before do
          allow(::OpenAI::Client).to receive(:new).and_return(mock_openai_client)
          allow(mock_openai_client).to receive(:responses).and_return(mock_responses)
          allow(mock_responses).to receive(:create).and_return(mock_api_response)
          allow(mock_api_response).to receive(:output).and_return([mock_output])
        end
  
        it 'successfully returns parsed JSON response' do
          result = client.run
  
          expect(result).to eq(response_data)
        end
  
        it 'calls OpenAI API with correct parameters' do
          expect(mock_responses).to receive(:create).with(
            model: "gpt-5-nano",
            input: [
              { role: :system, content: system_content },
              { role: :user, content: user_content }
            ]
          )
  
          client.run
        end
      end
    end
  end