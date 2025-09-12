class ChartsController < ApplicationController
	def show
		@chart = Chart.find(params[:id])
	end
	def new
		@chart = Chart.new
	end

	def create
		@chart = Chart.new(**chart_params)
		if @chart.save
			redirect_to @chart, notice: 'Chart was successfully created.'
		else
			render :new, status: :unprocessable_entity
		end
	end

	private

	def permitted_params
		params.require(:chart).permit(:name, :birth_date)
	end

	def chart_params
	{ first_name: name_splitter.first_name,
	  middle_name: name_splitter.middle_name,
	  last_name: name_splitter.last_name,
	  birth_date: permitted_params[:birth_date]
	}
	end

	def name_splitter
		@name_splitter ||= Charts::NameSplitter.new(full_name: permitted_params[:name])
	end
end
