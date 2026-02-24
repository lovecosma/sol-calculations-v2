class CelebrityChartsController < ApplicationController

  def index
    @charts = CelebrityChart.select(:id, :full_name, :birthdate, :profile_path, :updated_at, :created_at, :type)
                            .includes(chart_numbers: { numerology_number: [:number_type, :number] })
                            .order(created_at: :desc)
                            .page(params[:page])
    fresh_when @charts
  end
end
