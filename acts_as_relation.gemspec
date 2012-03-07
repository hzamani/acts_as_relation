# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'version'

Gem::Specification.new do |s|

  # Description Meta...
  s.name        = 'acts_as_relation'
  s.version     = ActiveRecord::ActsAsRelation::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Hassan Zamani'
  s.email       = 'hsn.zamani@gmail.com'
  s.homepage    = 'http://github.com/hzamani/acts_as_relation'
  s.summary     = 'Easy multi-table inheritance for rails'
  s.description = "This 'acts_as' extension provides multi-table inheritance for rails models."


  # Load Paths...
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']


  # Dependencies (installed via 'bundle install')...
  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rails"
  s.add_development_dependency "database_cleaner"
  s.add_dependency "activerecord"
end
