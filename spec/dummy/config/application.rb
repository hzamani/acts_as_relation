require File.expand_path('../boot', __FILE__)

require 'active_record/railtie'

Bundler.require
require 'acts_as_relation'

I18n.enforce_available_locales = false

module Dummy
  class Application < Rails::Application
  end
end
