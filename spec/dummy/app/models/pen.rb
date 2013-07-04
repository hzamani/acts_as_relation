class Pen < ActiveRecord::Base
  acts_as_superclass
  acts_as :product, as: 'producible'

  validates_presence_of :color
end
