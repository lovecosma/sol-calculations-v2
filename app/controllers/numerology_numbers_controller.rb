class NumerologyNumbersController < ApplicationController

def show
	@number = Number.find_by(value: params[:value])
	@number_type = NumberType.find_by(name: params[:number_type])
	@numerology_number = NumerologyNumber.find_by(number: @number, number_type: @number_type)
	if @numerology_number.blank?
		render plain: "Numerology number not found", status: :not_found
	else
		@matches = NumerologyNumber.includes(:number, :number_type).where(number_type: @number_type, number: { value: @numerology_number.match_ids } )
		@mismatches = NumerologyNumber.includes(:number, :number_type).where(number_type: @number_type, number: { value: @numerology_number.mismatch_ids } )
		render :show
	end
end
end
