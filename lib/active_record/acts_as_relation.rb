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
      def acts_as(model_name, scope=nil, options={})
        if scope.is_a?(Hash)
          options = scope
          scope   = nil
        end

        if options[:conditions]
          ActiveSupport::Deprecation.warn(":conditions is no longer supported by acts_as. Please use `where()` instead. Example: `acts_as :person, -> { where(name: 'John') }`")
        end
        if options[:include]
          ActiveSupport::Deprecation.warn(":include is no longer supported by acts_as. Please use `includes()` instead. Example: `acts_as :person, -> { includes(:friends) }`")
        end

        name             = model_name.to_s.underscore.singularize
        class_name       = options[:class_name] || name.camelcase
        association_name = options[:as] || acts_as_association_name(class_name)
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
          }

          acts_as_model.module_eval do
            singleton = class << self ; self end
            singleton.send :define_method, :included do |base|
              base.has_one name.to_sym, scope, has_one_options
              base.validate "#{name}_must_be_valid".to_sym
              base.alias_method_chain name.to_sym, :autobuild

              base.extend ActiveRecord::ActsAsRelation::AccessMethods
              attributes = class_name.constantize.content_columns.map(&:name)
              associations = class_name.constantize.reflect_on_all_associations.map(&:name)
              ignored = ["created_at", "updated_at", "#{association_name}_id", "#{association_name}_type", "#{association_name}"]
              attributes_to_delegate = attributes + associations - ignored
              base.send :define_acts_as_accessors, attributes_to_delegate, name

              if defined?(::ProtectedAttributes)
                base.attr_accessible.update(class_name.constantize.attr_accessible)
              end
            end

            define_method "#{name}_with_autobuild" do
              send("#{name}_without_autobuild") || send("build_#{name}")
            end

            define_method :method_missing do |method, *arg, &block|
              if (method.to_s == 'id' || method.to_s == name) || !send(name).respond_to?(method)
                super(method, *arg, &block)
              else
                send(name).send(method, *arg, &block)
              end
            end

            define_method 'respond_to?' do |method, include_private_methods = false|
              super(method, include_private_methods) || send(name).respond_to?(method, include_private_methods)
            end

            protected

            define_method "#{name}_must_be_valid" do
              unless send(name).valid?
                send(name).errors.each do |att, message|
                  errors.add(att, message)
                end
              end
            end
          end
        end

        class_eval do
          include "ActiveRecord::ActsAsModules::#{module_name}".constantize
        end

        if options.fetch :auto_join, true
          class_eval "default_scope -> { joins(:#{name}) }"
        end

        class_eval "default_scope -> { includes(:#{name}) }"

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
