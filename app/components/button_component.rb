# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  extend Dry::Initializer

  STYLES = {
    primary:   "bg-violet-500 hover:bg-violet-600 text-white border border-violet-500",
    secondary: "bg-white hover:bg-violet-50 text-black border border-violet-500"
  }.freeze

  option :label
  option :variant, default: -> { :primary }
  option :submit, default: -> { false }
  option :disabled, default: -> { false }

  def button_type
    submit ? "submit" : "button"
  end

  def css_classes
    classes = "font-bold py-2 px-8 rounded focus:outline-none focus:shadow-outline transition-colors self-end"
    classes += disabled ? " opacity-50 cursor-not-allowed" : " #{STYLES[variant]}"
    classes
  end
end
