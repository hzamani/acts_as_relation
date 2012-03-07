require 'spec_helper'

describe "create_table acts_as_superclass" do
  it "creates foreign key and type columns" do
    name = Pen.acts_as_association_name
    Pen.attribute_names.should include("#{name}_id")
    Pen.attribute_names.should include("#{name}_type")
  end

  it "when name passed creates foreign key and type columns with given name" do
    Product.attribute_names.should include("producible_id")
    Product.attribute_names.should include("producible_type")
  end
end
