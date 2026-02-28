class CelebrityChartsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @charts = CelebrityChart.eager_load(:celebrity)
                            .includes(chart_numbers: { numerology_number: [:number_type, :number] })
                            .order("celebrities.popularity DESC NULLS LAST")
    @charts = @charts.where("charts.full_name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @charts = @charts.page(params[:page])

    fresh_when @charts unless params[:q].present?
  end
end
