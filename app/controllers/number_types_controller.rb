class NumberTypesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @number_types = NumberType.order(:position)
    fresh_when @number_types, public: true
  end

  def show
    @number_type = NumberType.find_by(name: params[:number_type])
    @numerology_numbers = @number_type.numerology_numbers.includes(:number).order('numbers.value')
    fresh_when [@number_type, @numerology_numbers], public: true
  end
end
