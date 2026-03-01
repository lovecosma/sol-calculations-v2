class CelebrityChartsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @charts = CelebrityChart.eager_load(:celebrity)
                            .preload(ordered_chart_numbers: { numerology_number: [:number_type, :number] })
                            .order("celebrities.popularity DESC NULLS LAST")
    @charts = @charts.where("charts.full_name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    if params[:number_type].present? && params[:number_value].present?
      @charts = @charts.where(
        id: ChartNumber.joins(numerology_number: [:number_type, :number])
                       .where(number_types: { name: params[:number_type] }, numbers: { value: params[:number_value] })
                       .select(:chart_id)
      )
    end
    @charts = @charts.page(params[:page])

    @number_values = Number.order(:value).pluck(:value)
  end

  helper_method :filtering?

  private

  def filtering?
    params[:q].present? || params[:number_type].present? || params[:number_value].present?
  end
end
