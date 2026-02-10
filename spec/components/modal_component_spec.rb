# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModalComponent, type: :component do
  describe 'initialization' do
    it 'accepts id and title parameters' do
      component = described_class.new(id: 'test-modal', title: 'Test Title')
      expect(component.id).to eq('test-modal')
      expect(component.title).to eq('Test Title')
    end

    it 'requires id parameter' do
      expect { described_class.new(title: 'Test Title') }.to raise_error(ArgumentError)
    end

    it 'requires title parameter' do
      expect { described_class.new(id: 'test-modal') }.to raise_error(ArgumentError)
    end
  end

  describe 'rendering' do
    let(:component) { described_class.new(id: 'test-modal', title: 'Test Modal Title') }

    it 'renders the modal container with correct id' do
      render_inline(component)
      expect(page).to have_css('div[id="test-modal"]')
    end

    it 'renders with modal controller' do
      render_inline(component)
      expect(page).to have_css('div[data-controller="modal"]')
    end

    it 'renders the title' do
      render_inline(component)
      expect(page).to have_content(text: 'Test Modal Title')
    end
    
    it 'has close button' do
      render_inline(component)
      expect(page).to have_css('button[data-action="click->modal#close"]')
    end

    it 'renders modal container with click-outside handler' do
      render_inline(component)
      expect(page).to have_css('[data-action="click->modal#closeOnClickOutside"]')
    end

    it 'modal is hidden by default' do
      render_inline(component)
      expect(page).to have_css('.hidden[data-modal-target="container"]')
    end
  end

  describe 'with trigger slot' do
    let(:component) { described_class.new(id: 'test-modal', title: 'Test Modal') }

    it 'renders the trigger when provided' do
      render_inline(component) do |c|
        c.with_trigger { 'Open Modal' }
      end

      expect(page).to have_text('Open Modal')
    end

    it 'renders without trigger when not provided' do
      render_inline(component)
      expect(page).to have_css('div[data-controller="modal"]')
    end
  end

  describe 'with content' do
    let(:component) { described_class.new(id: 'test-modal', title: 'Test Modal') }

    it 'renders content in modal body' do
      render_inline(component) do
        'This is modal content'
      end

      expect(page).to have_text('This is modal content')
    end

    it 'renders content in styled container' do
      render_inline(component) do
        'Modal content'
      end

      expect(page).to have_css('.space-y-3.text-sm.text-gray-700', text: 'Modal content')
    end
  end
  

  describe 'accessibility' do
    let(:component) { described_class.new(id: 'test-modal', title: 'Test Modal') }

    it 'has button type for close button' do
      render_inline(component)
      expect(page).to have_css('button[type="button"]')
    end

    it 'renders title as h3' do
      render_inline(component)
      expect(page).to have_css('h3', text: 'Test Modal')
    end
  end
end
