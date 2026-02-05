# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charts::Numbers::Builder do
  let(:user) { create(:user) }
  let(:chart) { create(:chart, user: user) }
  let(:builder) { described_class.new(chart: chart) }
  
  
  
end
