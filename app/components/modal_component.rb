# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  extend Dry::Initializer

  renders_one :trigger

  option :id
  option :title
end
