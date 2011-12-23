module ActiveRecord
  module Acts
    module AsRelationSuperclassMigration

      def self.included(base)
        base.class_eval do
          alias_method_chain :create_table, :as_relation_superclass
        end
      end

      def create_table_with_as_relation_superclass(table_name, options = {})
        association_name = ActiveRecord::Base.acts_as_association_name table_name

        create_table_without_as_relation_superclass(table_name, options) do |td|
          if options[:as_relation_superclass]
            td.integer "#{association_name}_id"
            td.string "#{association_name}_type"
          end

          yield td if block_given?
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::SchemaStatements.send :include, ActiveRecord::Acts::AsRelationSuperclassMigration
