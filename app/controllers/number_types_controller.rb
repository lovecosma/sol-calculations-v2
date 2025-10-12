class NumberTypesController < ApplicationController

def show
	@number_type = NumberType.find_by(name: params[:number_type])
end


end
