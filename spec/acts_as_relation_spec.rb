require 'spec_helper'

describe "Submodel" do
  it "inherits Supermodel attributes" do
    pen = Pen.new
    ['name', 'name=', 'name_changed?', 'name_was', 'price', 'price=',
     'price_changed?', 'price_was'].each do |attribute|
      expect(pen).to respond_to(attribute)
    end

    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    expect(pen.name).to  eq('RedPen')
    expect(pen.price).to eq(0.8)
    expect(pen.color).to eq('red')

    pen.price = 0.9
    expect(pen.price_changed?).to be true
    expect(pen.price_was).to eq(0.8)
  end

  it "inherits Supermodel associations" do
    store = Store.create :name => 'Big Store'
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    pen.store = store
    pen.save
    expect(Pen.find(pen.id).store).to eq(store)
    expect(Pen.find(pen.id).product.store).to eq(store)
  end

  it "inherits Supermodel validations" do
    pen = Pen.new
    expect(pen).to be_invalid
    expect(pen.errors.keys).to include(:name, :price, :color)
  end

  it "inherits Supermodel methods" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    expect(pen).to respond_to('parent_method')
    expect(pen.parent_method).to eq("RedPen - 0.8")
  end

  it "raise NoMethodError correctly for Supermodel methods" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    expect(pen).to respond_to('dummy_raise_method')
    expect { pen.dummy_raise_method(nil) }.to raise_error(NoMethodError, /undefined method `dummy' for nil:NilClass/)
  end

  # it "inherits Supermodel dynamic finders" do
  #   pending
  #   pen = Pen.create :name => 'RedPen'
  #   product = Product.create :name => 'SomeProduct'
  #   Product.find_by_name('SomeProduct').should == product
  # end

  it "should raise NoMethodEror on unexisting method calls" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    expect { pen.unexisted_method }.to raise_error(NoMethodError)
  end

  it "destroies Supermodel on destroy" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    product_id = pen.product.id
    pen.destroy
    expect { Product.find product_id }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe "#acts_as_other_model?" do
    it "return true on models wich acts_as other ones" do
      expect(Pen.acts_as_other_model?).to be true
    end
  end

  describe "#acts_as_model_name" do
    it "returns name of model wich it acts as" do
      expect(Pen.acts_as_model_name).to eq(:product)
    end
  end

  describe "#is_a?" do
    it "should return true when the supermodel is passed" do
      product = Product.new
      expect(product.is_a?(Product)).to be true
      expect(product.instance_of?(Product)).to be true
      expect(product.kind_of?(Product)).to be true

      pen = Pen.new
      expect(pen.is_a?(Product)).to be true
      expect(pen.instance_of?(Product)).to be true
      expect(pen.kind_of?(Product)).to be true
    end
  end

  context "in a has_many relation" do
    it "should be appendable using << operator" do
      store = Store.create(:name => "Big Store")
      pen = Pen.create(:name => 'RedPen', :price => 0.8, :color => 'red')
      store.products << pen
      expect(pen.store).to eq(store)
    end

    it "should access child attributes" do
      store = Store.create(:name => "Big Store")
      pen = Pen.create(:name => 'RedPen', :price => 0.8, :color => 'red')
      store.products << pen
      store.reload
      expect(store.products.first.is_a?(Pen)).to be true
      expect(store.products.first).to eq(pen)
    end
  end

  it "have supermodel attr_accessibles as attr_accessibles" do
    if defined?(::ProtectedAttributes)
      Pen.attr_accessible[:default].each do |a|
        expect(Pencil.attr_accessible[:default]).to include(a)
      end
    end
  end

  it "should be findable" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    pen = Pen.find(pen.id)
    expect(pen).to be_valid
  end

  it "should be saveable" do
    pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
    pen = Pen.find(pen.id)
    expect { pen.save }.not_to raise_error
  end

  describe "Query Interface" do
    describe "auto_join" do
      it "automaticaly joins Supermodel on Submodel queries" do
        pen = Pen.create :name => 'RedPen',  :price => 0.8, :color => 'red'
        Pen.create :name => 'RedPen2', :price => 1.2, :color => 'red'
        Pen.create :name => 'BluePen', :price => 1.2, :color => 'blue'
        expect { Pen.where("price > 1").to_a }.not_to raise_error
        expect(Pen.where("name = ?", "RedPen")).to include(pen)
      end

      it "can be disabled by setting auto_join option to false" do
        expect { Pencil.where("name = 1").to_a }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end

describe "Supermodel" do
  describe "#specific" do
    it "returns the specific subclass object" do
      pen = Pen.create :name => 'RedPen', :price => 0.8, :color => 'red'
      expect(pen.product.specific).to eq(pen)
    end
  end
end
