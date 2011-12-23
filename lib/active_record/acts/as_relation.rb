module ActiveRecord
  module Acts
    module AsRelation
      def self.included(base)
        base.extend(ClassMethods)
      end

      module AccessMethods
        def define_acts_as_accessors(attribs, model_name)
          attribs.each do |attrib|
            class_eval <<-EndClass
              def #{attrib}
                #{model_name}.#{attrib}
              end

              def #{attrib}=(value)
                self.#{model_name}.#{attrib} = value
              end

              def #{attrib}?
                self.#{model_name}.#{attrib}?
              end
            EndClass
          end
        end
      end

      module ClassMethods
        def acts_as_association_name model_name = nil
          suffix = 'able'
          model_name = self.name unless model_name

          name = model_name.to_s.demodulize.singularize
          if name[-1].chr =~ /[^aeiou]/ || name[-2..-1] =~ /ge|ce/
            name = name + suffix
          elsif name[-7..-1] == 'ability'
            name = name[0..-8] + suffix
          else
            name = name[0..-2] + suffix
          end

          name.underscore
        end

        def acts_as(model_name)
          name = model_name.to_s.underscore.singularize
          association_name = acts_as_association_name name

          # Create A AsModel module
          as_model = Module.new
          Object.const_set("As#{name.camelcase}", as_model)

          as_model.module_eval <<-EndModule
            def self.included(base)
              base.has_one :#{name}, :as => :#{association_name}, :autosave => true, :validate => false, :dependent => :destroy
              base.validate :#{name}_must_be_valid
              base.alias_method_chain :#{name}, :autobuild

              base.extend ActiveRecord::Acts::AsRelation::AccessMethods
              all_attributes = #{name.camelcase.constantize}.content_columns.map(&:name)
              ignored_attributes = ["created_at", "updated_at", "#{association_name}_type"]
              associations = #{name.camelcase.constantize}.reflect_on_all_associations(:belongs_to).map! { |assoc| assoc.name }
              attributes_to_delegate = all_attributes - ignored_attributes + associations
              base.define_acts_as_accessors(attributes_to_delegate, "#{name}")
            end

            def #{name}_with_autobuild
              #{name}_without_autobuild || build_#{name}
            end

            def method_missing method, *arg, &block
              #{name}.send method, *arg, &block
            rescue NoMethodError
              super
            end

            def respond_to?(method, include_private_methods = false)
              super || self.#{name}.respond_to?(method, include_private_methods)
            end

            protected

            def #{name}_must_be_valid
              unless #{name}.valid?
                #{name}.errors.each do |att, message|
                  errors.add(att, message)
                end
              end
            end
          EndModule

          class_eval do
            include "As#{name.camelcase}".constantize
          end
        end

        def acts_as_superclass
          association_name = acts_as_association_name

          class_eval <<-CLASS
            belongs_to :#{association_name}, :polymorphic => true

            def specific_class
              self.#{association_name}
            end
          CLASS
        end

      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::AsRelation
