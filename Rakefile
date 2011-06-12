require 'rake'
require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
  s.name    = 'acts_as_relation'
  s.summary = 'Easy multi-table inheritance for rails'
  s.version = '0.0.1'
  s.author  = 'Hassan Zamani'
  s.email   = 'hsn.zamani@gmail.com'
  s.homepage = 'https://github.com/hzamani/acts_as_relation/'
  
  s.files = FileList['lib/**/*.rb', 'init.rb', 'README.markdown'].to_a
end
  
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

