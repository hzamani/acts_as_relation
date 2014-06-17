module ActiveRecord
  module ActsAsRelation
    extend ActiveSupport::Concern

    included do
      alias_method :acts_as?, :is_a?
    end

    module ClassMethods
      def acts_as(model_name, scope = nil, options = {})
        acts_as = ActsAs.new(model_name, scope, options)

        class_eval do
          include ActiveRecord::ActsAsRelation::ActsAsModules[acts_as]

          default_scope -> { includes(acts_as.name) }
        end

        class_eval { default_scope -> { joins(acts_as.name) } } if options.fetch :auto_join, ::ActsAsRelation::auto_join

        instance_eval <<-EndCode, __FILE__, __LINE__ + 1
          def acts_as_other_model?
            true
          end

          def acts_as_model_name
            "#{acts_as.name}".to_sym
          end
        EndCode
      end
      alias_method :is_a, :acts_as

      def acts_as_superclass(options = {})
        association_name = (options[:as] || acts_as_association_name).to_sym

        class_eval do
          belongs_to association_name, polymorphic: true, dependent: :delete

          alias_method :specific, association_name
          alias_method :specific_class, :specific

          def method_missing(method, *arg, &block)
            if specific && specific.respond_to?(method)
              specific.send(method, *arg, &block)
            else
              super
            end
          end

          def is_a?(klass)
            (specific && specific.class == klass) ? true : super
          end
          alias_method :instance_of?, :is_a?
          alias_method :kind_of?, :is_a?
        end
      end
      alias_method :is_a_superclass, :acts_as_superclass

      def is_a?(klass)
        if respond_to?(:acts_as_model_name) && acts_as_model_name == klass.name.downcase.to_sym
          true
        else
          super
        end
      end
      alias_method :acts_as?, :is_a?

      def acts_as_association_name(model_name = nil)
        model_name ||= name
        "as_#{model_name.to_s.demodulize.singularize.underscore}"
      end
    end
  end

  class Base
    include ActsAsRelation
  end
end
