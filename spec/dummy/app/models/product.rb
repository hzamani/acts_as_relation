class Product < ActiveRecord::Base
  acts_as_superclass
  belongs_to :store

  validates_presence_of :name, :price

  def parent_method
    "#{name} - #{price}"
  end
end
