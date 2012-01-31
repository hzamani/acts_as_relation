class Pencil < ActiveRecord::Base
  acts_as :product, :auto_join => false
end
