require 'active_record/acts/as_relation'
ActiveRecord::Base.send :include, ActiveRecord::Acts::AsRelation
