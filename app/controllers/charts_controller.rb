class ChartsController < ApplicationController
	def index
		@charts = current_user.charts.order(created_at: :desc)
	end

	def show
		@chart = current_user.charts.find(params[:id])
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

	def edit
		@chart = current_user.charts.find(params[:id])
	end

	def update
		@chart = current_user.charts.find(params[:id])
		if @chart.update(**permitted_params)
			redirect_to chart_path @chart
		else
			render :edit, status: :unprocessable_entity
		end
	end
	
	def destroy
		@chart = current_user.charts.find(params[:id])
		@chart.destroy
		redirect_to charts_path, notice: "Chart deleted successfully."
	end

	private

	def permitted_params
		params.require(:chart).permit(:full_name, :birthdate, :user_id)
	end
end
