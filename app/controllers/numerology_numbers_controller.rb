class NumerologyNumbersController < ApplicationController
	before_action :set_numerology_number, only: [:show]
	before_action :set_matches_and_mismatches, only: [:show]

	def show
		fresh_when @numerology_number
	end

	private

	def set_numerology_number
		@numerology_number = NumerologyNumber
			.joins(:number, :number_type)
			.includes(:number, :number_type)
			.find_by(
				numbers: { value: params[:value] },
				number_types: { name: params[:number_type] }
			)

		if @numerology_number.blank?
			render plain: "Numerology number not found", status: :not_found
			return
		end

		@number = @numerology_number.number
		@number_type = @numerology_number.number_type
	end

	def set_matches_and_mismatches
		return unless @numerology_number.present?

		@matches = NumerologyNumber.includes(:number, :number_type)
		                            .where(number_type: @number_type, number: { value: @numerology_number.match_ids })
		@mismatches = NumerologyNumber.includes(:number, :number_type)
		                              .where(number_type: @number_type, number: { value: @numerology_number.mismatch_ids })
	end
end
