require 'rubygems'
require 'active_record'
require 'acts_as_relation'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.define(:version => 1) do

  create_table :stores do |t|
    t.string :store_name
  end

  create_table :products, :as_relation_superclass => true do |t|
    t.string  :name
    t.float   :price
  end

  create_table :pens, :as_relation_superclass => true do |t|
    t.string  :color
  end

  create_table :pencils
  create_table :availabilities
end

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

class Availability < ActiveRecord::Base
end
