class Product < ActiveRecord::Base
  acts_as_superclass
end

class OtherProduct < ActiveRecord::Base
  acts_as_superclass
end
