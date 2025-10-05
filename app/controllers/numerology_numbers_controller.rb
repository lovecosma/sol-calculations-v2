class NumerologyNumbersController < ApplicationController

def show
	@number = Number.find_by(value: params[:value])
	@number_type = NumberType.find_by(name: params[:number_type])
	@numerology_number = NumerologyNumber.find_by(number: @number, number_type: @number_type)
	@matches = NumerologyNumber.where(number_type: @number_type, number_id: @numerology_number.match_ids)
	@mismatches = NumerologyNumber.where(number_type: @number_type, number_id: @numerology_number.mismatch_ids )
	if @numerology_number.nil?
		render plain: "Numerology number not found", status: :not_found
	else
		render :show
	end
end
end
