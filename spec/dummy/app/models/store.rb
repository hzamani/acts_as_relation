class Store < ActiveRecord::Base
	attr_accessible :name
	
	has_many :products
end
