class ChartsController < ApplicationController
	before_action :authenticate_user!, except: [:show]

	def index
		@charts = current_user.charts.order(created_at: :desc)
	end

	def show
		@chart = Chart.find(params[:id])
	end

	def new
		@chart = Chart.new
	end

	def create
		@chart = current_user.charts.build(**permitted_params)
		if @chart.save
			redirect_to chart_path @chart
		else
			render :new, status: :unprocessable_entity
		end
	end

	private

	def permitted_params
		params.require(:chart).permit(:full_name, :birthdate, :user_id)
	end
end
