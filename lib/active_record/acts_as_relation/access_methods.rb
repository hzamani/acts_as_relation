module ActiveRecord
  module ActsAsRelation
    module AccessMethods
      protected
      def define_acts_as_accessor(attrib, model_name)
        class_eval do
          define_method attrib do
            send(model_name).send(attrib)
          end

          define_method "#{attrib}=" do |value|
            send(model_name).send("#{attrib}=", value)
          end

          define_method "#{attrib}?" do
            send(model_name).send("#{attrib}?")
          end
        end
      end

      def define_acts_as_accessors(attribs, model_name)
        attribs.each do |attrib|
          define_acts_as_accessor(attrib, model_name)
        end
      end
    end
  end
end
