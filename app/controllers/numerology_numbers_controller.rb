class NumerologyNumbersController < ApplicationController
	before_action :set_numerology_number, only: [:show]
	before_action :set_matches_and_mismatches, only: [:show]

	def show
	end

	private

	def set_numerology_number
		@number = Number.find_by(value: params[:value])
		@number_type = NumberType.find_by(name: params[:number_type])
		@numerology_number = NumerologyNumber.find_by(number: @number, number_type: @number_type)

		if @numerology_number.blank?
			render plain: "Numerology number not found", status: :not_found
		end
	end

	def set_matches_and_mismatches
		return unless @numerology_number.present?

		@matches = NumerologyNumber.includes(:number, :number_type)
		                            .where(number_type: @number_type, number: { value: @numerology_number.match_ids })
		@mismatches = NumerologyNumber.includes(:number, :number_type)
		                              .where(number_type: @number_type, number: { value: @numerology_number.mismatch_ids })
	end
end
