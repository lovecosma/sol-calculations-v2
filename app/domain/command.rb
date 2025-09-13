module Command
def self.included(base)
base.include Dry::Initializer
base.define_singleton_method(:run) do |args|
	new(**args).run
end
end
end
