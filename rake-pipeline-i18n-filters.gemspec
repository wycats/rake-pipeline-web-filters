# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rake-pipeline-i18n-filters/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Randy Morgan"]
  gem.email         = ["digital.ipseity@gmail.com"]
  gem.description   = %q{A collection of i18n web filters for rake-pipeline}
  gem.summary       = %q{Adds filters for generating i18n-js and Ember.STRINGS localization data from i18n yaml}
  gem.homepage      = "http://github.com/randym/rake-pipeline-i18n-filters"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rake-pipeline-i18n-filters"
  gem.require_paths = ["lib"]
  gem.version       = Rake::Pipeline::I18n::Filters::VERSION

  gem.add_dependency "rake-pipeline", "~> 0.6"
  gem.add_dependency "rack"
  gem.add_development_dependency "rspec"
  #gem.add_development_dependency "tilt"
  #gem.add_development_dependency "sass"
  #gem.add_development_dependency "compass"
  #gem.add_development_dependency "coffee-script"
  #gem.add_development_dependency "redcarpet", '~> 2.0'
  #gem.add_development_dependency "yui-compressor"
  #gem.add_development_dependency "uglifier"
  #gem.add_development_dependency "less"
  #gem.add_development_dependency "json"
  #gem.add_development_dependency "therubyracer"
end
