module ActsAsSuperclassSchema
  def self.migrate
    ActiveRecord::Base.establish_connection(
      :adapter  => "sqlite3",
      :database => ":memory:"
    )
    ActiveRecord::Schema.define do
      suppress_messages do
        create_table :products, :as_relation_superclass => true do |t|
        end
      end
    end

    require Pathname(__FILE__).parent.join("models.rb")
  end
end

module ActsAsSuperclassWithNameSchema
  def self.migrate
    ActiveRecord::Base.establish_connection(
      :adapter  => "sqlite3",
      :database => ":memory:"
    )
    ActiveRecord::Schema.define do
      suppress_messages do
        create_table :other_products, :as_relation_superclass => :producible do |t|
        end
      end
    end

    require Pathname(__FILE__).parent.join("models.rb")
  end
end
