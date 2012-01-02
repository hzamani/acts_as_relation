require 'test_helper'

class ActsAsRelationTest < ActiveSupport::TestCase

  test "acts as validation" do
    pen = Pen.new
    assert !pen.valid?
    assert_equal pen.errors.keys, [:name, :price, :color]

    pen.name = "TestPen"
    assert !pen.valid?
    assert_equal pen.errors.keys, [:price, :color]

    pencil = Pencil.new
    assert !pencil.valid?
    assert_equal pencil.errors.keys, [:name, :price, :color]

    pencil.color = "red"
    assert !pencil.valid?
    assert_equal pencil.errors.keys, [:name, :price]
  end

  test "save model" do
    assert Pen.new(:name=>"FOO", :color=>"black", :price=>0.89).save
    pen = Pen.new
    pen.name = "BAR"
    pen.color = "red"
    pen.price = 0.99
    assert pen.save
  end

  test "access methods" do
    assert_nothing_raised(ActiveRecord::UnknownAttributeError) do
      Pen.new(:name=>"RedPen", :price=>0.59, :color=>"red")
      Pencil.new(:name=>"RedPencil", :price=>0.59, :color=>"red")
    end
  end

  test "acts as method missing" do
    assert_nothing_raised(NoMethodError) do
      pen = Pen.new
      pen.name_changed?
      pen.price_changed?
      pen.name_was

      pencil = Pencil.new
      pencil.name_changed?
      pencil.price_changed?
      pencil.name_was
      pencil.color_was
    end
  end

  test "acts as respond to?" do
    pen = Pen.new
    assert(pen.respond_to? :name_changed?)
    assert(pen.respond_to? :name_was)
    assert(pen.respond_to? :price_will_change!)

    pencil = Pencil.new
    assert(pencil.respond_to? :name_changed?)
    assert(pencil.respond_to? :name_was)
    assert(pencil.respond_to? :price_will_change!)
    assert(pencil.respond_to? :color_changed?)
    assert(pencil.respond_to? :color_was)
  end

  test "association reflections" do
    store = Store.new
    pen = Pen.new
    pen.store = store

    assert_equal store, pen.product.store
    assert_equal store, pen.store
  end

  test "call parent methods" do
    pen = Pen.new(:name=>"RedPen", :price=>0.59, :color=>"red")
    assert_equal pen.parent_method, "RedPen - 0.59"
  end

  test "call unexisted method" do
    assert_raise NoMethodError do
      pen = Pen.new
      pen.unexisted_method
    end

  end

  test "acts as association name" do
    assert_equal Availability.acts_as_association_name, 'available'
    assert_equal Pencil.acts_as_association_name, 'pencilable'
    assert_equal Pencil.acts_as_association_name( Pen ), 'penable'
  end

  test "acts as superclass" do
    pen = Pen.create(:name => "RedPen", :price => 0.59, :color => "red")
    product = pen.product

    assert_equal product.specific_class.class, Pen
  end

  test "destroy action" do
    pen = Pen.create(:name => "RedPen", :price => 0.59, :color => "red")
    product = pen.product

    pen.destroy

    assert_raise ActiveRecord::RecordNotFound do
      Product.find product.id
    end
    assert_raise ActiveRecord::RecordNotFound do
      Pen.find pen.id
    end
  end

end

#ActiveRecord::Base.connection.tables.each do |table|
#  ActiveRecord::Base.connection.drop_table(table)
#end

