module ActiveRecord
  module ActsAsRelationSuperclassMigration
    def self.included(base)
      base.class_eval do
        alias_method_chain :create_table, :as_relation_superclass
      end
    end

    def create_table_with_as_relation_superclass(table_name, options = {})
      create_table_without_as_relation_superclass(table_name, options) do |td|
        if superclass = options[:as_relation_superclass]
          association_name = if superclass.is_a? Symbol or superclass.is_a? String then
                               superclass
                             else
                               ActiveRecord::Base.acts_as_association_name table_name
                             end

          td.integer "#{association_name}_id"
          td.string  "#{association_name}_type"
        end

        yield td if block_given?
      end
    end
  end
end

module ActiveRecord::ConnectionAdapters::SchemaStatements
  include ActiveRecord::ActsAsRelationSuperclassMigration
end
