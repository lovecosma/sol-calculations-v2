module Charts
	class NameSplitter
		extend Dry::Initializer

		option :full_name, default: proc { '' }

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
	end
end