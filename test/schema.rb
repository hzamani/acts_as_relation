require 'rubygems'
require 'active_record'
require 'acts_as_relation'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.define(:version => 1) do
  create_table :products do |t|
    t.string  :name
    t.float   :price
    t.string  :product_type
    t.integer :product_id
  end
  
  create_table :pens do |t|
    t.string  :color
  end
  
  create_table :pencils
end

class Product < ActiveRecord::Base
  validates_presence_of :name, :price
end

class Pen < ActiveRecord::Base
  acts_as :product
  validates_presence_of :color
end

class Pencil < ActiveRecord::Base
  acts_as :pen
end
