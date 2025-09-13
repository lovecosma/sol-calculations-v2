class ChartsController < ApplicationController
	def show
		@chart = Chart.find(params[:id])
	end
	def new
		@chart = Chart.new
	end

	def create
		@chart = Chart.new(**permitted_params)
		if @chart.save
			redirect_to chart_path @chart
		else
			render :new, status: :unprocessable_entity
		end
	end

	private

	def permitted_params
		params.require(:chart).permit(:full_name, :birthdate)
	end
end
