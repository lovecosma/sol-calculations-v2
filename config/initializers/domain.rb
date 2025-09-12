
domain_path = File.expand_path('app/domain', Rails.root)
$LOAD_PATH.unshift(domain_path) unless $LOAD_PATH.include?(domain_path)
Dir[File.join(domain_path, '**', '*.rb')].sort.each { |file| require file }
