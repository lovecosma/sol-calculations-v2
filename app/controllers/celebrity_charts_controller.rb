class CelebrityChartsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :number_values]

  def index
    @charts = CelebrityChart.eager_load(:celebrity)
                            .preload(ordered_chart_numbers: { numerology_number: [:number_type, :number] })
                            .order("celebrities.popularity DESC NULLS LAST")
    @charts = @charts.search_by_name(params[:q]) if params[:q].present?
    if params[:number_type].present? && params[:number_value].present?
      @charts = @charts.with_number(params[:number_type], params[:number_value])
    end
    @charts = @charts.page(params[:page])

    @number_values = fetch_number_values(params[:number_type])
  end

  def number_values
    render partial: "number_value_select", locals: { number_values: fetch_number_values(params[:number_type]) }
  end

  helper_method :filtering?

  private

  def filtering?
    params[:q].present? || params[:number_type].present? || params[:number_value].present?
  end

  def fetch_number_values(number_type)
    if number_type.present?
      Number.joins(numerology_numbers: :number_type)
            .where(number_types: { name: number_type })
            .order(:value)
            .pluck(:value)
    else
      Number.order(:value).pluck(:value)
    end
  end
end
