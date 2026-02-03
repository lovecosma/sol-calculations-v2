require 'dry-initializer'

module Command
def self.included(base)
base.extend Dry::Initializer
base.define_singleton_method(:run) do |args|
	new(**args).run
end
end
end
