class CreatePens < ActiveRecord::Migration
  def change
    create_table :pens, as_relation_superclass: true do |t|
      t.string :color

      t.timestamps
    end
  end
end
