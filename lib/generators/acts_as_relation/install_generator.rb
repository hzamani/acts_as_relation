module ActsAsRelation
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Copy acts_as_relation default files'
      source_root File.expand_path('../templates', __FILE__)

      def copy_initializers
        copy_file 'config.rb', 'config/initializers/acts_as_relation.rb'
      end
    end
  end
end
