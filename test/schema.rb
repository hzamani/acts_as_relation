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

  create_table :products do |t|
    t.string  :name
    t.float   :price
    t.string  :product_type
    t.integer :product_id
  end

  create_table :pens do |t|
    t.string  :color
    t.integer :pen_id
    t.string :pen_type
  end

  create_table :pencils
end

class Store < ActiveRecord::Base
  has_many :products
end

class Product < ActiveRecord::Base
  belongs_to :store
  validates_presence_of :name, :price

  def hello
    "#{name} - #{price}$"
  end
end

class Pen < ActiveRecord::Base
  acts_as :product
  validates_presence_of :color
end

class Pencil < ActiveRecord::Base
  acts_as :pen
end
