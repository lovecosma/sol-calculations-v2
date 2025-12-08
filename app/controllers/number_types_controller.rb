class NumberTypesController < ApplicationController

	def show
		@number_type = NumberType.find_by(name: params[:number_type])
		@numerology_numbers = @number_type.numerology_numbers.includes(:number).order('numbers.value')
	end

end
