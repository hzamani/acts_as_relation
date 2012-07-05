class Pen < ActiveRecord::Base
  acts_as_superclass
  acts_as :product, as: 'producible'

  attr_accessible :name, :price, :color

  validates_presence_of :color
end
