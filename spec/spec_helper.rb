require 'coveralls'
Coveralls.wear!

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'rake'
Dummy::Application.load_tasks
Rake::Task['db:test:prepare'].invoke

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
end
