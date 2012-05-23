class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, as_relation_superclass: 'producible' do |t|
      t.string :name
      t.float :price
      t.integer :store_id

      t.timestamps
    end
  end
end
