class CreatePencils < ActiveRecord::Migration
  def change
    create_table :pencils do |t|

      t.timestamps
    end
  end
end
