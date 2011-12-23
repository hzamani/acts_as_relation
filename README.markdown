Acts As Realation
=================

Easy multi-table inheritance for rails.
With `acts_as_relation` models inherit parent model:

 * columns
 * validations
 * methods

Multi-table inheritance
-----------------------

Multi-table inheritance happens when each model in the hierarchy is a model all by itself
that corresponds to its own database table and can be queried and created individually.
The inheritance relationship introduces links between the child model and each of its
parents (via an automatically-created `has_one` associations).

Example
-------

Required columns on parent model name `parent1` are

 1. `parent1_type`
 2. `parent1_id`

generate models

    $ rails g model product name:string price:float
    Add next option to Product Migration:
    create_table :products, :as_relation_superclass => true
    ...

    $ rails g model pen color:string

add some validations and instance methods

    class Product < ActiveRecord::Base
      validates_presence_of :name, :price

      def hello
        puts "Hello, My name is '#{name}', my price is $#{price}."
      end
    end

product is superclass for all kind of products:

    class Product < ActiveRecord::Base
      acts_as_superclass
    end

pen inherits from product

    class Pen < ActiveRecord::Base
      acts_as :product
    end

to get some specific class(as example: specific product - Pen) from superclass can be used method specific_class:

    Pen.create :name => 'Pen A', :color=> 'black', :price => 0.42
    product = Product.first
    product.specific_class # will be instance of Pen class

to get name of association used between superclass and children can be used method acts_as_association_name:

    Product.acts_as_association_name # 'Productable'

after deleting specific object will removed linked superobject:

    Pen.first.destroy # delete as Pen row as linked Product row

pen inherits products validations and columns

    p = Pen.new
    p.valid? => false
    p.errors => {:name=>["can't be blank"], :price=>["can't be blank"]}

pen inherits product methods

    pen = Pen.new(:name=>"Red Pen", :color=>:red, :price=>0.99)
    pen.hello => Hello, My name is 'Red Pen', my price is $0.99.

we can make queries on both models

    Product.where("price <= 1")
    Pen.where("color = ?", color)

---

Copyright (c) 2011 Hassan Zamani, released under the MIT license.
