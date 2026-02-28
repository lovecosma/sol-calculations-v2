class CelebrityChart < Chart
  has_one :celebrity, foreign_key: :celebrity_chart_id
end
