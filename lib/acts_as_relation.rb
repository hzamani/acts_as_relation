require 'active_record/acts_as_relation'
require 'active_record/acts_as_relation/acts_as'
require 'active_record/acts_as_relation/access_methods'
require 'active_record/acts_as_relation/acts_as_modules'
require 'active_record/acts_as_relation/superclass_migration'

module ActsAsRelation
  mattr_accessor :auto_join
  @@auto_join = Rails::VERSION::MAJOR >= 3 ? false : true

  # Set-up method for plugin configuration
  def self.setup
    yield self
  end
end

