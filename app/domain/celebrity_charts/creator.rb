# frozen_string_literal: true

module CelebrityCharts
  class Creator
    include Command

    option :celebrity

    def run
      return if celebrity.celebrity_chart_id

      chart = CelebrityChart.create!(
        full_name: celebrity.original_name,
        birthdate: celebrity.birthdate
      )
      celebrity.update!(celebrity_chart: chart)
    end
  end
end
