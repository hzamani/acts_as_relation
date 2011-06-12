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

    $ rails g model product name:string price:float product_type:string product_id:integer
    $ rails g model pen color:string

add some validations and instance methods

    class Product < ActiveRecord::Base
      validates_presence_of :name, :price
      
      def hello
        puts "Hello, My name is '#{name}', my price is $#{price}."
      end
    end

pen inherits from product

    class Pen < ActiveRecord::Base
      acts_as :product
    end

pen inhetits products validations and colomns

    p = Pen.new
    p.valid? => false
    p.errors => {:name=>["can't be blank"], :price=>["can't be blank"]}
     
pen inherits proudct methods

    pen = Pen.new(:name=>"Red Pen", :color=>:red, :price=>0.99)
    pen.hello => Hello, My name is 'Red Pen', my price is $0.99.
    
we can make queries on both models

    Product.where("price <= 1")
    Pen.where("color = ?", color)

---

Copyright (c) 2011 Hassan Zamani, released under the MIT license.
