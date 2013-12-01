module ActiveRecord

  module ActsAsModules end

  module ActsAsRelation
    extend ActiveSupport::Concern

    module AccessMethods
      protected
      def define_acts_as_accessors(attribs, model_name)
        attribs.each do |attrib|
          code = <<-EndCode
            def #{attrib}
              #{model_name}.#{attrib}
            end

            def #{attrib}=(value)
              #{model_name}.#{attrib} = value
            end

            def #{attrib}?
              #{model_name}.#{attrib}?
            end
          EndCode
          class_eval code, __FILE__, __LINE__
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

          code = <<-EndCode

            def parent_association_attributes
              associations = #{class_name}.reflect_on_all_associations.map(&:name)
              ignored = ["created_at", "updated_at", "#{association_name}_id", "#{association_name}_type", "#{association_name}"]
              (associations - ignored).collect {|a| a.to_s + '_id'}
            end

            def self.included(base)
              base.has_one :#{name}, #{has_one_options}
              base.validate :#{name}_must_be_valid
              base.alias_method_chain :#{name}, :autobuild

              base.extend ActiveRecord::ActsAsRelation::AccessMethods
              attributes = #{class_name}.content_columns.map(&:name)
              associations = #{class_name}.reflect_on_all_associations.map(&:name)
              ignored = ["created_at", "updated_at", "#{association_name}_id", "#{association_name}_type", "#{association_name}"]
              attributes_to_delegate = attributes + associations - ignored
              base.send :define_acts_as_accessors, attributes_to_delegate, "#{name}"

              base.attr_accessible.update(#{class_name}.attr_accessible)
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

            def [](key)
              if parent_association_attributes.include? key.to_s
                #{name}[key]
              else
                super
              end
            end

            def []=(key, value)
              if parent_association_attributes.include? key.to_s
                #{name}[key] = value
              else
                super
              end
            end

            def is_a?(model_class)
              if model_class.name.underscore.to_sym == :#{name}
                return true
              else
                super
              end
            end
            alias_method :instance_of?, :is_a?
            alias_method :kind_of?, :is_a?

            protected

            def #{name}_must_be_valid
              unless #{name}.valid?
                #{name}.errors.each do |att, message|
                  errors.add(att, message)
                end
              end
            end

          EndCode
          acts_as_model.module_eval code, __FILE__, __LINE__
        end

        class_eval do
          include "ActiveRecord::ActsAsModules::#{module_name}".constantize
        end

        if options.fetch :auto_join, true
          class_eval "default_scope joins(:#{name})"
        end

        class_eval "default_scope includes(:#{name})"

        code = <<-EndCode
          def acts_as_other_model?
            true
          end

          def acts_as_model_name
            :#{name}
          end
        EndCode
        instance_eval code, __FILE__, __LINE__
      end
      alias :is_a :acts_as

      def acts_as_superclass options={}
        association_name = options[:as] || acts_as_association_name

        code = <<-EndCode
          belongs_to :#{association_name}, :polymorphic => true

          def specific
            self.#{association_name}
          end
          alias :specific_class :specific

          def method_missing method, *arg, &block
            if specific and specific.respond_to?(method, false)
              specific.send(method, *arg, &block)
            else
              super
            end
          end

          def is_a?(model_class)
            if specific and specific.class == model_class
              return true
            else
              super
            end
          end
          alias_method :instance_of?, :is_a?
          alias_method :kind_of?, :is_a?

        EndCode
        class_eval code, __FILE__, __LINE__
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
