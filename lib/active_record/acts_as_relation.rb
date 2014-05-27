module ActiveRecord
  module ActsAsRelation
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as(model_name, scope=nil, options={})
        acts_as = ActsAs.new(model_name, scope, options)

        class_eval do
          include acts_as.module

          default_scope -> { includes(acts_as.name) }
        end

        class_eval { default_scope -> { joins(acts_as.name) } } if options.fetch :auto_join, true

        instance_eval <<-EndCode, __FILE__, __LINE__
          def acts_as_other_model?
            true
          end

          def acts_as_model_name
            "#{acts_as.name}".to_sym
          end
        EndCode
      end
      alias :is_a :acts_as

      def acts_as_superclass options={}
        association_name = options[:as] || acts_as_association_name

        class_eval <<-EndCode, __FILE__, __LINE__
          belongs_to :#{association_name}, :polymorphic => true

          def specific
            self.#{association_name}
          end
          alias :specific_class :specific

          def method_missing method, *arg, &block
            if specific and specific.respond_to?(method)
              specific.send(method, *arg, &block)
            else
              super
            end
          end

          def is_a? klass
            (specific and specific.class == klass) ? true : super
          end
          alias_method :instance_of?, :is_a?
          alias_method :kind_of?, :is_a?
        EndCode
      end
      alias :is_a_superclass :acts_as_superclass

      def acts_as_association_name model_name=nil
        model_name ||= self.name
        "as_#{model_name.to_s.demodulize.singularize.underscore}"
      end
    end
  end
end

class ActiveRecord::Base
  include ActiveRecord::ActsAsRelation
end
