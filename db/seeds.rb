# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
number_types = %w(
  life_path
  expression
  soul_urge
  personality
  birthday
)

number_types.each do |type_name|
NumberType.find_or_create_by(name: type_name)
end
puts "Seeded NumberType records."
numbers = (1..9).to_a + [11, 22, 33]
numbers.each do |num_value|
	Number.find_or_create_by(value: num_value)
end
puts "Seeded Number records."
numerology_numbers = NumberType.all.to_a.product(Number.all)
numerology_numbers.each do |type, number|
	NumerologyNumber.find_or_create_by(number_type: type, number: number)
end
puts "Seeded NumerologyNumber records."
NumerologyNumber.all.each do |numerology_number|
  Descriptions::Fetcher.new(numerology_number:).run
end
puts "Seeding completed."
