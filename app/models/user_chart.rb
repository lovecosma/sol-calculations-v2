class UserChart < Chart
  # Keep URL helpers and form routing pointing to /charts
  def self.model_name
    Chart.model_name
  end

  belongs_to :user
end
