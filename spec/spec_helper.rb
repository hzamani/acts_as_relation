require 'active_record'
require 'acts_as_relation'

Dir[Pathname(__FILE__).parent.join "*/*schema.rb"].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
