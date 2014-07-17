module ActiveRecord
  module ActsAsRelation
    module SuperclassMigration
      def self.included(base)
        base.class_eval do
          alias_method_chain :create_table, :as_relation_superclass
        end
      end

      def create_table_with_as_relation_superclass(table_name, options = {})
        create_table_without_as_relation_superclass(table_name, options) do |t|
          if options.key? :as_relation_superclass
            name = options[:as_relation_superclass]
            if name == true
              name = ActiveRecord::Base.acts_as_association_name table_name
            end

            t.integer "#{name}_id"
            t.string "#{name}_type"
            t.index ["#{name}_id", "#{name}_type"], name: "#{table_name}_#{name}_index"
          end

          yield t if block_given?
        end
      end
    end
  end

  module ConnectionAdapters::SchemaStatements
    include ActsAsRelation::SuperclassMigration
  end
end
