class Store < ActiveRecord::Base
  has_many :products
end

class Product < ActiveRecord::Base
  acts_as_superclass

  belongs_to :store
  validates_presence_of :name, :price

  def parent_method
    "#{name} - #{price}"
  end
end

class Pen < ActiveRecord::Base
  acts_as_superclass

  acts_as :product
  validates_presence_of :color
end

class Pencil < ActiveRecord::Base
  acts_as :pen
end
