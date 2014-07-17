require File.expand_path('../boot', __FILE__)

require 'active_record/railtie'

Bundler.require
require 'acts_as_relation'

module Dummy
  class Application < Rails::Application
  end
end
