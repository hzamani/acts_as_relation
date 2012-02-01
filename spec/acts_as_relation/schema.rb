module ActsAsRelationSchema
  def self.migrate
    ActiveRecord::Base.establish_connection(
      :adapter  => "sqlite3",
      :database => ":memory:"
    )
    ActiveRecord::Schema.define do
      suppress_messages do
        create_table :stores do |t|
          t.string :store_name
        end

        create_table :products, :as_relation_superclass => true do |t|
          t.string  :name
          t.float   :price
        end

        create_table :pens, :as_relation_superclass => true do |t|
          t.string  :color
        end

        create_table :pencils
      end
    end

    require Pathname(__FILE__).parent.join("models.rb")
  end
end
