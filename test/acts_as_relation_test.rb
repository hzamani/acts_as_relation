require 'test_helper'

class ActsAsRelationTest < ActiveSupport::TestCase
  
  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

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
  
end
