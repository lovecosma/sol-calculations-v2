class NumberTypesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @number_types = NumberType.order(:position)
  end

  def show
    @number_type = NumberType.find_by(name: params[:number_type])
    @numerology_numbers = @number_type.numerology_numbers.includes(:number).order('numbers.value')
  end
end
