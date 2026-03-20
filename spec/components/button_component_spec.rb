# frozen_string_literal: true

require "rails_helper"

RSpec.describe ButtonComponent, type: :component do
  describe "rendering" do
    it "renders the label" do
      render_inline(described_class.new(label: "Click me"))
      expect(page).to have_text("Click me")
    end

    it "renders a button element" do
      render_inline(described_class.new(label: "Click me"))
      expect(page).to have_css("button")
    end
  end

  describe "button type" do
    it "defaults to type=button" do
      render_inline(described_class.new(label: "Click me"))
      expect(page).to have_css('button[type="button"]')
    end

    it "renders type=submit when submit: true" do
      render_inline(described_class.new(label: "Click me", submit: true))
      expect(page).to have_css('button[type="submit"]')
    end
  end

  describe "variant" do
    it "defaults to the primary variant" do
      render_inline(described_class.new(label: "Click me"))
      expect(page).to have_css("button.bg-violet-500")
    end

    it "renders primary styles" do
      render_inline(described_class.new(label: "Click me", variant: :primary))
      expect(page).to have_css("button.bg-violet-500.text-white")
    end

    it "renders secondary styles" do
      render_inline(described_class.new(label: "Click me", variant: :secondary))
      expect(page).to have_css("button.bg-white.text-black")
    end
  end

  describe "disabled state" do
    it "is not disabled by default" do
      render_inline(described_class.new(label: "Click me"))
      expect(page).not_to have_css("button[disabled]")
    end

    it "sets the disabled attribute when disabled: true" do
      render_inline(described_class.new(label: "Click me", disabled: true))
      expect(page).to have_css("button[disabled]")
    end

    it "applies disabled styles when disabled" do
      render_inline(described_class.new(label: "Click me", disabled: true))
      expect(page).to have_css("button.opacity-50.cursor-not-allowed")
    end

    it "does not apply variant styles when disabled" do
      render_inline(described_class.new(label: "Click me", disabled: true))
      expect(page).not_to have_css("button.bg-violet-500")
    end
  end

  describe "initialization" do
    it "requires label" do
      expect { described_class.new }.to raise_error(Dry::Initializer::MissingValueError)
    end
  end
end
