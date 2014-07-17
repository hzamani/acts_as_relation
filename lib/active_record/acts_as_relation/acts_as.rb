module ActiveRecord
  module ActsAsRelation
    class ActsAs
      attr_accessor :module
      attr_reader :name, :class_name, :model, :association_name, :module_name, :module_name, :scope, :options

      def initialize(model_name, scope = nil, options = {})
        @model_name = model_name
        @options, @scope = scope.is_a?(Hash) ? [scope, nil] : [options, scope]

        @name             = @model_name.to_s.underscore.singularize.to_sym
        @class_name       = @options[:class_name] || @name.to_s.camelcase
        @model            = @class_name.constantize
        @association_name = @options[:as] || @model.acts_as_association_name
        @module_name      = "ActsAs#{name.to_s.camelcase}"
      end

      def parent_relations
        @parent_relations ||= (model.reflect_on_all_associations.map(&:name) - [association_name]).map { |a| a.to_s + '_id' }
      end

      def has_one_options
        @has_one_options ||= {
          as:         association_name,
          class_name: class_name,
          inverse_of: association_name.to_sym,
          autosave:   true,
          validate:   false,
          dependent:  options.fetch(:dependent, :destroy)
        }
      end
    end
  end
end
