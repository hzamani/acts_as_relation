module ActiveRecord
  module ActsAsRelation
    module ActsAsModules
      class << self
        def module_for acts_as
          create_module(acts_as) unless const_defined? acts_as.module_name
          "ActiveRecord::ActsAsRelation::ActsAsModules::#{acts_as.module_name}".constantize
        end

        def create_module(acts_as)
          acts_as_model_module = Module.new
          const_set(acts_as.module_name, acts_as_model_module)
          acts_as_model_module.extend ActiveSupport::Concern

          has_one_options = {
            as:         acts_as.association_name,
            class_name: acts_as.class_name,
            autosave:   true,
            validate:   false,
            dependent:  acts_as.options.fetch(:dependent, :destroy),
          }

          acts_as_model_module.included do
            has_one acts_as.name, acts_as.scope, has_one_options
            validate "#{acts_as.name}_must_be_valid".to_sym
            alias_method_chain acts_as.name, :autobuild

            extend ActiveRecord::ActsAsRelation::AccessMethods
            define_acts_as_accessors(acts_as.attributes_to_delegate, acts_as.name)

            if defined?(::ProtectedAttributes)
              attr_accessible.update(acts_as.model.attr_accessible)
            end
          end

          acts_as_model_module.module_eval do
            class_methods = Module.new
            const_set('ClassMethods', class_methods)

            define_method "#{acts_as.name}_with_autobuild" do
              result = send("#{acts_as.name}_without_autobuild")
              unless result
                result = send("build_#{acts_as.name}")
                result.send("#{acts_as.association_name}=", self)
              end
              result
            end

            define_method :method_missing do |method, *arg, &block|
              if (method.to_s == 'id' || method.to_s == name) || !send(acts_as.name).respond_to?(method)
                super(method, *arg, &block)
              else
                send(acts_as.name).send(method, *arg, &block)
              end
            end

            define_method :respond_to? do |method, include_private_methods=false|
              super(method, include_private_methods) || send(acts_as.name).respond_to?(method, include_private_methods)
            end

            define_method :is_a? do |klass|
              klass.name == acts_as.class_name ? true : super(klass)
            end

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
                super(key,value)
              end
            end

            protected

            define_method "#{acts_as.name}_must_be_valid" do
              unless send(acts_as.name).valid?
                send(acts_as.name).errors.each do |att, message|
                  errors.add(att, message)
                end
              end
            end
          end
        end
      end
    end
  end
end
