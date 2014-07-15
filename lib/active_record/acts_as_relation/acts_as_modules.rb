module ActiveRecord
  module ActsAsRelation
    module ActsAsModules
      class << self
        def [](acts_as)
          if const_defined? acts_as.module_name
            const_get acts_as.module_name
          else
            acts_as_module = Module.new
            const_set acts_as.module_name, acts_as_module
            acts_as.module = acts_as_module
            create_assocication(acts_as)
            autobuild_superclass(acts_as)
            validate_superclass(acts_as)
            make_superclass_methods_accessible(acts_as)
            make_superclass_attributes_accessible(acts_as)
            fix_is_a(acts_as)
          end
        end

        def create_assocication(acts_as)
          acts_as.module.extend ActiveSupport::Concern
          acts_as.module.included do
            has_one acts_as.name, acts_as.scope, acts_as.has_one_options
            alias_method_chain acts_as.name, :autobuild

            validate "#{acts_as.name}_must_be_valid".to_sym

            extend ActiveRecord::ActsAsRelation::AccessMethods
            define_acts_as_accessors(acts_as.name)

            if defined?(::ProtectedAttributes)
              attr_accessible.update(acts_as.model.attr_accessible)
            end

            # active_enum gem
            if acts_as.class_name.constantize.respond_to?(:enumerate)
              define_active_enum_forwarders(acts_as.class_name)
            end
          end
        end

        def autobuild_superclass(acts_as)
          acts_as.module.module_eval do
            define_method "#{acts_as.name}_with_autobuild" do
              send("#{acts_as.name}_without_autobuild") || send("build_#{acts_as.name}")
            end
          end
        end

        def make_superclass_methods_accessible(acts_as)
          acts_as.module.module_eval do
            define_method :method_missing do |method, *arg, &block|
              if (method.to_s == 'id' || method.to_s == acts_as.name) || !send(acts_as.name).respond_to?(method)
                super(method, *arg, &block)
              else
                class_eval do
                  delegate method, to: acts_as.name
                end
                send(acts_as.name).send(method, *arg, &block)
              end
            end

            define_method :respond_to? do |method, include_private_methods = false|
              super(method, include_private_methods) || send(acts_as.name).respond_to?(method, include_private_methods)
            end
          end
        end

        def fix_is_a(acts_as)
          acts_as.module.module_eval do
            define_method :is_a? do |klass|
              klass.name == acts_as.class_name ? true : super(klass)
            end
            alias_method :acts_as?, :is_a?
          end
        end

        def make_superclass_attributes_accessible(acts_as)
          acts_as.module.module_eval do
            define_method :[] do |key|
              if acts_as.parent_relations.include?(key.to_s)
                send(acts_as.name)[key]
              else
                super(key)
              end
            end

            define_method :[]= do |key, value|
              if acts_as.parent_relations.include?(key.to_s)
                send(acts_as.name)[key] = value
              else
                super(key, value)
              end
            end
          end
        end

        def validate_superclass(acts_as)
          acts_as.module.module_eval do
            define_method "#{acts_as.name}_must_be_valid" do
              unless send(acts_as.name).valid?
                send(acts_as.name).errors.each do |att, message|
                  errors.add(att, message)
                end
              end
            end
            protected "#{acts_as.name}_must_be_valid".to_sym
          end
        end
      end
    end
  end
end
