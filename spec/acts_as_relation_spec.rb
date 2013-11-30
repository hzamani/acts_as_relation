require 'spec_helper'

describe "Submodel" do
  it "inherits Supermodel attributes" do
    pen = Pen.new
    ['name', 'name=', 'name_changed?', 'name_was',
     'price', 'price=', 'price_changed?', 'price_was'].each do |m|
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
      pen.should respond_to(m)
    end

    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    pen.name.should  == 'RedPen'
    pen.price.should == 0.8
    pen.color.should == 'red'

    pen.price = 0.9
    pen.price_changed?.should be_true
    pen.price_was.should == 0.8
  end

  it "inherits Supermodel associations" do
    store = Store.create :name => 'Big Store'
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    pen.store = store
    pen.save
    Pen.find(pen.id).store.should == store
    Pen.find(pen.id).product.store.should == store
  end

  it "inherits Supermodel validations" do
    pen = Pen.new
    pen.should be_invalid
    pen.errors.keys.should include(:name, :price, :color)
  end

  it "inherits Supermodel methods" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    pen.should respond_to('parent_method')
    pen.parent_method.should == "RedPen - 0.8"
  end

  # it "inherits Supermodel dynamic finders" do
  #   pending
  #   pen = Pen.create :name => 'RedPen'
  #   product = Product.create :name => 'SomeProduct'
  #   Product.find_by_name('SomeProduct').should == product
  # end

  it "should raise NoMethodEror on unexisting method calls" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    lambda { pen.unexisted_method }.should raise_error(NoMethodError)
  end

  it "destroies Supermodel on destroy" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    product_id = pen.product.id
    pen.destroy
    lambda { Product.find product_id }.should raise_error(ActiveRecord::RecordNotFound)
  end

  describe "#acts_as_other_model?" do
    it "return true on models wich acts_as other ones" do
      Pen.acts_as_other_model?.should be_true
    end
  end

  describe "#acts_as_model_name" do
    it "returns name of model wich it acts as" do
      Pen.acts_as_model_name.should == :product
    end
  end

  it "have supermodel attr_accessibles as attr_accessibles" do
    Pen.attr_accessible[:default].each do |a|
      Pencil.attr_accessible[:default].should include(a)
    end
  end

  it "should be findable" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    pen = Pen.find(pen.id)
    pen.should be_valid
  end

  it "should be saveable" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    pen = Pen.find(pen.id)
    lambda { pen.save }.should_not raise_error
  end

  describe "acts as the superclass in has_many relations" do
    it "should return true for is_a? method when the supermodel is passed" do 
      (Product.new.is_a? Product).should be_true
      pen = Pen.new(:name => 'RedPen', :price => 0.8, :color => 'red')
      (pen.is_a? Product).should be_true
    end

    it "should be appendable using << operator in a has_many relation" do
      store = Store.new(name: "Big Store")
      store.products << Pen.new(:name => 'RedPen', :price => 0.8, :color => 'red')
      store.save!
    end

    it "should sets the parent_id when using the << operator" do
      store = Store.new(name: "Big Store")
      store.products << Pen.new(:name => 'RedPen', :price => 0.8, :color => 'red')
      store.save!
   
      store.products.each do |product|
        product.store.should_not be_nil
        product.store_id.should_not be_nil
        product[:store_id].should_not be_nil
      end
    end

    it "should access the child attributes in a has_many relation" do
      store = Store.new(name: "Big Store")
      store.products << Pen.new(:name => 'RedPen', :price => 0.8, :color => 'red')
      store.save!

      store.reload

      store.products.first.color.should eq 'red'
    end
  end

  describe "Query Interface" do
    describe "auto_join" do
      it "automaticaly joins Supermodel on Submodel queries" do
        pen = Pen.create :name => 'RedPen',  :price => 0.8, :color => 'red'
        Pen.create :name => 'RedPen2', :price => 1.2, :color => 'red'
        Pen.create :name => 'BluePen', :price => 1.2, :color => 'blue'
        lambda { Pen.where("price > 1").to_a }.should_not raise_error(ActiveRecord::StatementInvalid)
        Pen.where("name = ?", "RedPen").should include(pen)
      end

      it "can be disabled by setting auto_join option to false" do
        lambda { Pencil.where("name = 1").to_a }.should raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end

describe "Supermodel" do
  describe "#specific" do
    it "returns the specific subclass object" do
      pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
      pen.product.specific.should == pen
    end
  end
end
