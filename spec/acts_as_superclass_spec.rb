require 'spec_helper'

describe 'create_table acts_as_superclass' do
  it 'creates foreign key and type columns' do
    name = Pen.acts_as_association_name
    expect(Pen.attribute_names).to include("#{name}_id")
    expect(Pen.attribute_names).to include("#{name}_type")
  end

  it 'when name passed creates foreign key and type columns with given name' do
    expect(Product.attribute_names).to include('producible_id')
    expect(Product.attribute_names).to include('producible_type')
  end
end
