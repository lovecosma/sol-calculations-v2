# frozen_string_literal: true

class Celebrity < ApplicationRecord
  belongs_to :celebrity_chart, optional: true
end
