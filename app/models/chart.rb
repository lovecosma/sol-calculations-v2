class Chart < ApplicationRecord
belongs_to :user

validates :full_name, presence: true, length: { maximum: 100 }
validates :birthdate, presence: true
validate :validate_full_name_format
has_many :chart_numbers, dependent: :destroy

after_commit :build_numbers, on: [:create, :update], if: :should_build_numbers?

def first_name
name_parts.first
end

def middle_name
name_parts[1] || ''
end

def last_name
name_parts.size > 1 ? name_parts.last : ''
end

def normalized_name
	# Convert to uppercase and remove all non-letter characters for numerology calculations
	full_name.upcase.gsub(/[^A-Z]/, '')
end

private

def validate_full_name_format
	return if full_name.blank?

	# Must contain only allowed characters: letters, spaces, hyphens, apostrophes, periods
	unless full_name.match?(/\A[A-Za-z\s\-'.]+\z/)
		errors.add(:full_name, "can only contain letters, spaces, hyphens, apostrophes, and periods. Numbers and symbols are not allowed.")
		return
	end

	# Must contain at least one letter
	unless full_name.match?(/[A-Za-z]/)
		errors.add(:full_name, "must contain at least one letter")
		return
	end

	# Normalize multiple spaces to single space
	self.full_name = full_name.squeeze(' ').strip
end

def name_parts
	# Split by spaces, but keep hyphens and apostrophes as part of names
	@name_parts ||= full_name.strip.split(/\s+/).reject(&:blank?)
end

def should_build_numbers?
	# Build numbers on create, or on update if name or birthdate changed
	saved_change_to_full_name? || saved_change_to_birthdate?
end

def build_numbers
	Charts::Numbers::Builder.run(chart: self)
end

end
