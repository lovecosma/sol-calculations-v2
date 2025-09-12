class ChartsController < ApplicationController
	def new
		@chart = Chart.new
	end

	def create
		@name_splitter = ::Charts::NameSplitter.new(full_name: params[:chart][:name])
		chart_params = { first_name: @name_splitter.first_name,
		                 middle_name: @name_splitter.middle_name,
		                 last_name: @name_splitter.last_name,
		                 birth_date: params[:chart][:birth_date]
										}

		@chart = Chart.new(**chart_params)
		fail

		if @chart.save
			redirect_to @chart, notice: 'Chart was successfully created.'
		else
			render :new, status: :unprocessable_entity
		end
	end
end
