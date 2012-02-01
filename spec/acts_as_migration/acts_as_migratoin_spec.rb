require 'spec_helper'

describe "create_table acts_as_superclass" do
  before :all do
    ActsAsSuperclassSchema.migrate
  end

  it "creates foreign key and type columns on" do
    name = Product.acts_as_association_name
    Product.attribute_names.should include("#{name}_id")
    Product.attribute_names.should include("#{name}_type")
  end
end

describe "create_table acts_as_superclass option withname" do
  before :all do
    ActsAsSuperclassWithNameSchema.migrate
  end

  it "creates foreign key and type columns on" do
    OtherProduct.attribute_names.should include("producible_id")
    OtherProduct.attribute_names.should include("producible_type")
  end
end
