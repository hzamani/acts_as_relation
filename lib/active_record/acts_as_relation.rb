module ActiveRecord

  module ActsAsModules end

  module ActsAsRelation
    extend ActiveSupport::Concern

    module AccessMethods
      protected
      def define_acts_as_accessors(attribs, model_name)
        attribs.each do |attrib|
          class_eval <<-EndEval
            def #{attrib}
              #{model_name}.#{attrib}
            end

            def #{attrib}=(value)
              #{model_name}.#{attrib} = value
            end

            def #{attrib}?
              #{model_name}.#{attrib}?
            end
          EndEval
        end
      end
    end

    module ClassMethods
      def acts_as(model_name, options={})
        name             = model_name.to_s.underscore.singularize
        class_name       = options[:class_name] || name.camelcase
        association_name = options[:as] || acts_as_association_name(name)
        module_name      = "ActsAs#{name.camelcase}"

        unless ActiveRecord::ActsAsModules.const_defined? module_name
          # Create ActsAsModel module
          acts_as_model = Module.new
          ActiveRecord::ActsAsModules.const_set(module_name, acts_as_model)

          has_one_options = {
            :as         => association_name,
            :class_name => class_name,
            :autosave   => true,
            :validate   => false,
            :dependent  => options.fetch(:dependent, :destroy),
            :include    => options[:include],
            :conditions => options[:conditions]
          }

          acts_as_model.module_eval <<-EndEval
            def self.included(base)
              base.has_one :#{name}, #{has_one_options}
              base.validate :#{name}_must_be_valid
              base.alias_method_chain :#{name}, :autobuild

              base.extend ActiveRecord::ActsAsRelation::AccessMethods
              all_attributes = #{class_name}.content_columns.map(&:name)
              ignored_attributes = ["created_at", "updated_at", "#{association_name}_id", "#{association_name}_type"]
              associations = #{class_name}.reflect_on_all_associations.map! { |assoc| assoc.name } - ["#{association_name}"]
              attributes_to_delegate = all_attributes - ignored_attributes + associations
              base.send :define_acts_as_accessors, attributes_to_delegate, "#{name}"
            end

            def #{name}_with_autobuild
              #{name}_without_autobuild || build_#{name}
            end

            def method_missing method, *arg, &block
              raise NoMethodError if method.to_s == 'id' || method.to_s == '#{name}'

              #{name}.send(method, *arg, &block)
            rescue NoMethodError
              super
            end

            def respond_to?(method, include_private_methods = false)
              super || #{name}.respond_to?(method, include_private_methods)
            end

            protected

            def #{name}_must_be_valid
              unless #{name}.valid?
                #{name}.errors.each do |att, message|
                  errors.add(att, message)
                end
              end
            end
          EndEval
        end

        class_eval do
          include "ActiveRecord::ActsAsModules::#{module_name}".constantize
        end

        if options.fetch :auto_join, true
          class_eval "default_scope joins(:#{name})"
        end

        instance_eval <<-EndEval
          def acts_as_other_model?
            true
          end

          def acts_as_model_name
            :#{name}
          end
        EndEval
      end
      alias :is_a :acts_as

      def acts_as_superclass
        association_name = acts_as_association_name

        class_eval <<-EndEval
          belongs_to :#{association_name}, :polymorphic => true

          def specific
            self.#{association_name}
          end
          alias :specific_class :specific
        EndEval
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
