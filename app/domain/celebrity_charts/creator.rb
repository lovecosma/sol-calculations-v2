# frozen_string_literal: true

module CelebrityCharts
	class Creator
		include Command

		option :celebrity_data

		def run
			full_name = celebrity_data["original_name"].to_s.strip
			birthday  = celebrity_data["birthday"]
			profile_path = celebrity_data["profile_path"]

			return if full_name.blank? || birthday.blank?

			CelebrityChart.find_or_create_by(full_name: full_name) do |chart|
				chart.birthdate = Date.parse(birthday)
				chart.profile_path = profile_path
			end
		end
	end
end
