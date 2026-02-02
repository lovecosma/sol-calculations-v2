# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
NumerologyNumber.destroy_all
NumberType.destroy_all
Number.destroy_all

number_types = %w(
  life_path
  expression
  soul_urge
  personality
)
number_types.each do |type_name|
NumberType.find_or_create_by(name: type_name)
end
puts "Seeded NumberType records."
numbers = (1..31).to_a + [11, 22, 33]
numbers.each do |num_value|
	Number.find_or_create_by(value: num_value)
end


puts "Seeded Number records."
numerology_numbers = NumberType.where.not(name: 'birthday').to_a.product(Number.where(value: (1..9).to_a + [11, 22, 33]))
numerology_numbers.each do |type, number|
	NumerologyNumber.find_or_create_by(number_type: type, number: number)
end

birthday_type = NumberType.find_by(name: 'birthday')
Number.where(value: (1..31).to_a).each do |number|
	NumerologyNumber.find_or_create_by(number_type: birthday_type, number:)
end
puts "Seeded NumerologyNumber records."

# Generate AI descriptions for all numerology numbers
total = NumerologyNumber.count
success_count = 0
failure_count = 0

puts "Generating AI descriptions for #{total} numerology numbers (this may take several minutes)..."

NumerologyNumber.all.each_with_index do |numerology_number, index|
	begin
		NumerologyNumbers::Descriptions::Builder.run(numerology_number:)
		success_count += 1
		print "." if (index + 1) % 10 == 0
	rescue NumerologyNumbers::Descriptions::Builder::OpenAIError => e
		failure_count += 1
		puts "\nFailed to generate description for #{numerology_number.number_type.name} #{numerology_number.number.value}: #{e.message}"
	rescue StandardError => e
		failure_count += 1
		puts "\nUnexpected error for #{numerology_number.number_type.name} #{numerology_number.number.value}: #{e.class} - #{e.message}"
	end
end

puts "\n\nSeeding completed."
puts "Successfully generated #{success_count} descriptions"
puts "Failed to generate #{failure_count} descriptions" if failure_count > 0
