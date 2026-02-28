# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chart, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it 'belongs to user' do
      chart = build(:chart, user: user)
      expect(chart.user).to eq(user)
    end

    it 'has many chart_numbers' do
      chart = create(:chart, user: user)
      expect(chart).to respond_to(:chart_numbers)
    end
  end

  describe 'validations' do
    it 'validates presence of full_name' do
      chart = build(:chart, user: user, full_name: nil)
      expect(chart).not_to be_valid
      expect(chart.errors[:full_name]).to include("can't be blank")
    end

    it 'validates presence of birthdate' do
      chart = build(:chart, user: user, birthdate: nil)
      expect(chart).not_to be_valid
      expect(chart.errors[:birthdate]).to include("can't be blank")
    end

    it 'validates length of full_name' do
      chart = build(:chart, user: user, full_name: 'a' * 101)
      expect(chart).not_to be_valid
      expect(chart.errors[:full_name]).to include('is too long (maximum is 100 characters)')
    end

    describe 'full_name format validation' do
      it 'accepts names with letters and spaces' do
        chart = build(:chart, user: user, full_name: 'John Doe')
        expect(chart).to be_valid
      end

      it 'accepts a hyphenated first name' do
        chart = build(:chart, user: user, full_name: 'Mary-Jane Smith')
        expect(chart).to be_valid
      end

      it 'accepts a hyphenated last name' do
        chart = build(:chart, user: user, full_name: 'Anne Smith-Jones')
        expect(chart).to be_valid
      end

      it 'accepts a fully hyphenated name' do
        chart = build(:chart, user: user, full_name: 'Mary-Jane Smith-Jones')
        expect(chart).to be_valid
      end

      it 'accepts names with apostrophes' do
        chart = build(:chart, user: user, full_name: "O'Connor")
        expect(chart).to be_valid
      end

      it 'rejects names with periods' do
        chart = build(:chart, user: user, full_name: 'John. Doe')
        expect(chart).not_to be_valid
        expect(chart.errors[:full_name]).to include(/can only contain letters/)
      end

      it 'rejects names with numbers' do
        chart = build(:chart, user: user, full_name: 'John3')
        expect(chart).not_to be_valid
        expect(chart.errors[:full_name]).to include(/can only contain letters/)
      end

      it 'rejects names with special symbols' do
        chart = build(:chart, user: user, full_name: 'John@Doe')
        expect(chart).not_to be_valid
        expect(chart.errors[:full_name]).to include(/can only contain letters/)
      end

      it 'rejects names with no letters' do
        chart = build(:chart, user: user, full_name: '---')
        expect(chart).not_to be_valid
        expect(chart.errors[:full_name]).to include(/must contain at least one letter/)
      end

      it 'strips a title prefix before validating' do
        chart = create(:chart, user: user, full_name: 'Dr. Robert Smith')
        expect(chart.full_name).to eq('Robert Smith')
      end

      it 'strips a generation suffix before validating' do
        chart = create(:chart, user: user, full_name: 'Robert Downey Jr.')
        expect(chart.full_name).to eq('Robert Downey')
      end

      it 'strips both a prefix and suffix before validating' do
        chart = create(:chart, user: user, full_name: 'Mr. Robert Downey Jr.')
        expect(chart.full_name).to eq('Robert Downey')
      end

      it 'normalizes multiple spaces to single space' do
        chart = create(:chart, user: user, full_name: 'John    Doe')
        expect(chart.full_name).to eq('John Doe')
      end

      it 'strips leading and trailing spaces' do
        chart = create(:chart, user: user, full_name: '  John Doe  ')
        expect(chart.full_name).to eq('John Doe')
      end
    end
  end

  describe '#first_name' do
    it 'returns the first part of the name' do
      chart = build(:chart, user: user, full_name: 'John Doe')
      expect(chart.first_name).to eq('John')
    end

    it 'returns the only name for single names' do
      chart = build(:chart, user: user, full_name: 'Madonna')
      expect(chart.first_name).to eq('Madonna')
    end

    it 'handles hyphenated first names' do
      chart = build(:chart, user: user, full_name: 'Mary-Jane Smith')
      expect(chart.first_name).to eq('Mary-Jane')
    end
  end

  describe '#middle_name' do
    it 'returns the middle part of three-part names' do
      chart = build(:chart, user: user, full_name: 'John Michael Doe')
      expect(chart.middle_name).to eq('Michael')
    end

    it 'returns the second part for two-part names' do
      chart = build(:chart, user: user, full_name: 'John Doe')
      expect(chart.middle_name).to eq('Doe')
    end

    it 'returns empty string for single names' do
      chart = build(:chart, user: user, full_name: 'Madonna')
      expect(chart.middle_name).to eq('')
    end
  end

  describe '#last_name' do
    it 'returns the last part of the name' do
      chart = build(:chart, user: user, full_name: 'John Doe')
      expect(chart.last_name).to eq('Doe')
    end

    it 'returns empty string for single names' do
      chart = build(:chart, user: user, full_name: 'Madonna')
      expect(chart.last_name).to eq('')
    end

    it 'returns the last part for three-part names' do
      chart = build(:chart, user: user, full_name: 'John Michael Doe')
      expect(chart.last_name).to eq('Doe')
    end
  end

  describe '#normalized_name' do
    it 'converts to uppercase' do
      chart = build(:chart, user: user, full_name: 'john doe')
      expect(chart.normalized_name).to eq('JOHNDOE')
    end

    it 'removes spaces' do
      chart = build(:chart, user: user, full_name: 'John Doe')
      expect(chart.normalized_name).to eq('JOHNDOE')
    end

    it 'removes hyphens' do
      chart = build(:chart, user: user, full_name: 'Mary-Jane')
      expect(chart.normalized_name).to eq('MARYJANE')
    end

    it 'removes apostrophes' do
      chart = build(:chart, user: user, full_name: "O'Connor")
      expect(chart.normalized_name).to eq('OCONNOR')
    end

    it 'removes hyphens and apostrophes' do
      chart = build(:chart, user: user, full_name: "Mary-Jane O'Connor")
      expect(chart.normalized_name).to eq('MARYJANEOCONNOR')
    end

    it 'removes all non-letter characters' do
      chart = build(:chart, user: user, full_name: "Mary-Jane O'Connor Jr.")
      expect(chart.normalized_name).to eq('MARYJANEOCONNORJR')
    end
  end

  describe 'callbacks' do
    before do
      allow(Charts::Numbers::Builder).to receive(:run)
    end
    describe '#build_numbers' do
      it 'is called after create' do
        create(:chart, user: user)
        expect(Charts::Numbers::Builder).to have_received(:run)
      end

      it 'is called after update when name changes' do
        chart = create(:chart, user: user, full_name: 'John Doe')
        chart.update(full_name: 'Jane Doe')
        expect(Charts::Numbers::Builder).to have_received(:run).twice
      end

      it 'is called after update when birthdate changes' do
        chart = create(:chart, user: user, birthdate: Date.new(1990, 1, 1))
        chart.update(birthdate: Date.new(1991, 1, 1))
        expect(Charts::Numbers::Builder).to have_received(:run).twice
      end

      it 'is not called when other attributes change' do
        chart = create(:chart, user: user)
        chart.touch
        expect(Charts::Numbers::Builder).to have_received(:run).once
      end

      it 'destroys existing chart_numbers before rebuilding' do
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy).to receive(:destroy_all).and_call_original
        chart = create(:chart, user: user, full_name: 'John Doe')
        chart.update(full_name: 'Jane Doe')
        expect(chart.chart_numbers).to have_received(:destroy_all).twice
      end
    end
  end

  describe 'on create' do
    it 'creates a valid chart' do
      chart = build(:chart, user: user)
      expect(chart).to be_valid
    end

    it 'triggers number building' do
      expect(Charts::Numbers::Builder).to receive(:run)
      create(:chart, user: user)
    end
  end

  describe 'on update' do
    let(:chart) { create(:chart, user: user, full_name: 'John Doe') }

    context 'when name changes' do
      it 'rebuilds chart numbers' do
        allow(Charts::Numbers::Builder).to receive(:run).and_call_original
        expect(Charts::Numbers::Builder).to receive(:run).and_call_original

        chart.update(full_name: 'Jane Smith')
      end
      
      it 'destroys old chart numbers before rebuilding' do
        allow(chart.chart_numbers).to receive(:destroy_all).and_call_original
        chart.update(full_name: 'Jane Smith')
        expect(chart.chart_numbers).to have_received(:destroy_all)
      end
    end

    context 'when name does not change' do
      it 'does not rebuild chart numbers' do
        original_count = chart.chart_numbers.count

        chart.touch

        expect(chart.chart_numbers.reload.count).to eq(original_count)
      end
    end
  end
end
