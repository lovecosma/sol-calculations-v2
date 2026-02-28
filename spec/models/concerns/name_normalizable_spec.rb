# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NameNormalizable do
  subject(:host) { Class.new { include NameNormalizable }.new }

  describe '#strip_affixes' do
    describe 'prefixes' do
      {
        'Mr Robert Smith'    => 'Robert Smith',
        'Mr. Robert Smith'   => 'Robert Smith',
        'Mrs Jane Doe'       => 'Jane Doe',
        'Mrs. Jane Doe'      => 'Jane Doe',
        'Ms Emily White'     => 'Emily White',
        'Miss Clara Brown'   => 'Clara Brown',
        'Dr James Wilson'    => 'James Wilson',
        'Dr. James Wilson'   => 'James Wilson',
        'Rev Thomas Grant'   => 'Thomas Grant',
        'Prof Sarah Lee'     => 'Sarah Lee',
        'Sir Walter Scott'   => 'Walter Scott',
        'Lady Diana Spencer' => 'Diana Spencer',
        'Lord Byron'         => 'Byron',
      }.each do |input, expected|
        it "strips '#{input.split.first}' prefix" do
          expect(host.strip_affixes(input)).to eq(expected)
        end
      end
    end

    describe 'suffixes' do
      {
        'Robert Smith Jr'    => 'Robert Smith',
        'Robert Smith Jr.'   => 'Robert Smith',
        'Robert Smith, Jr.'  => 'Robert Smith',
        'Jane Doe Sr'        => 'Jane Doe',
        'Jane Doe Sr.'       => 'Jane Doe',
        'Robert Smith II'    => 'Robert Smith',
        'Robert Smith III'   => 'Robert Smith',
        'Robert Smith IV'    => 'Robert Smith',
        'Robert Smith V'     => 'Robert Smith',
        'John Adams PhD'     => 'John Adams',
        'John Adams PhD.'    => 'John Adams',
        'John Adams MD'      => 'John Adams',
        'John Adams Esq'     => 'John Adams',
        'John Adams JD'      => 'John Adams',
      }.each do |input, expected|
        it "strips '#{input.split.last.delete('.,').rstrip}' suffix" do
          expect(host.strip_affixes(input)).to eq(expected)
        end
      end
    end

    describe 'prefix and suffix together' do
      it 'strips both from a fully decorated name' do
        expect(host.strip_affixes('Mr. Robert Downey Jr.')).to eq('Robert Downey')
      end

      it 'strips both when neither has periods' do
        expect(host.strip_affixes('Dr Robert Smith Jr')).to eq('Robert Smith')
      end
    end

    describe 'case insensitivity' do
      it 'strips lowercase prefixes' do
        expect(host.strip_affixes('dr. James Wilson')).to eq('James Wilson')
      end

      it 'strips uppercase suffixes' do
        expect(host.strip_affixes('Robert Smith JR')).to eq('Robert Smith')
      end
    end

    describe 'names without affixes' do
      it 'returns the name unchanged' do
        expect(host.strip_affixes('Robert Downey')).to eq('Robert Downey')
      end

      it 'returns a single name unchanged' do
        expect(host.strip_affixes('Madonna')).to eq('Madonna')
      end
    end

    describe 'mid-name words that resemble affixes' do
      it 'does not strip a prefix-like word that is not at the start' do
        expect(host.strip_affixes('Robert Dr Smith')).to eq('Robert Dr Smith')
      end

      it 'does not strip a suffix-like word that is not at the end' do
        expect(host.strip_affixes('Robert Jr Smith')).to eq('Robert Jr Smith')
      end
    end
  end
end
