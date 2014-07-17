module ActiveRecord
  module ActsAsRelation
    module AccessMethods
      def define_acts_as_accessors(model_name)
        # The weird order of the if-else branches is so that we query ourselves
        # before we query our superclass.
        class_eval <<-EndCode, __FILE__, __LINE__ + 1
          def read_attribute(attr_name, *args, &proc)
            if attribute_method?(attr_name.to_s)
              super(attr_name, *args)
            else
              #{model_name}.read_attribute(attr_name, *args, &proc)
            end
          end

          def touch(name = nil, *args, &proc)
            if attribute_method?(name.to_s)
              super(name, *args, &proc)
            else
              super(nil, *args, &proc)
              #{model_name}.touch(name, *args, &proc)
            end
          end

          def save(*args)
            super(*args) && #{model_name}.save(*args)
          end

          def save!(*args)
            super(*args) && #{model_name}.save!(*args)
          end

          private

          def write_attribute(attr_name, *args, &proc)
            if attribute_method?(attr_name.to_s)
              super(attr_name, *args)
            else
              #{model_name}.send(:write_attribute, attr_name, *args, &proc)
            end
          end
        EndCode
      end

      protected :define_acts_as_accessors
    end
  end
end
