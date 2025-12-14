class Chart < ApplicationRecord
belongs_to :user

validates :full_name, presence: true, format: {
	with: /\A\s*\S+(?:\s+\S+){0,2}\s*\z/,
	message: "must be first middle last name only"
}
validates :birthdate, presence: true
has_many :chart_numbers, dependent: :destroy

after_save :build_numbers

def first_name
name_parts.first
end

def middle_name
name_parts[1] || ''
end

def last_name
name_parts.size > 1 ? name_parts.last : ''
end

private

def name_parts
@name_parts ||= full_name.split(' ')
end

def build_numbers
Charts::Numbers::Builder.run(chart: self)
end

end
