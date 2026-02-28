class CelebrityChartsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @charts = CelebrityChart.select(:id, :full_name, :birthdate, :updated_at, :created_at, :type)
                            .includes(:celebrity, chart_numbers: { numerology_number: [:number_type, :number] })
                            .joins(:celebrity)
                            .order("celebrities.popularity DESC NULLS LAST")
    @charts = @charts.where("charts.full_name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @charts = @charts.page(params[:page])
    fresh_when @charts unless params[:q].present?
  end
end
