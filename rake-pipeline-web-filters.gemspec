# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rake-pipeline-web-filters/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yehuda Katz"]
  gem.email         = ["wycats@gmail.com"]
  gem.description   = %q{A collection of web filters for rake-pipeline}
  gem.summary       = %q{Contributed filters for use in rake-pipeline that are useful for web projects, like asset management}
  gem.homepage      = "http://github.com/wycats/rake-pipeline-web-filters"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rake-pipeline-web-filters"
  gem.require_paths = ["lib"]
  gem.version       = Rake::Pipeline::Web::Filters::VERSION

  gem.add_dependency "rake-pipeline", "~> 0.6"
  gem.add_dependency "rack"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "tilt"
  gem.add_development_dependency "sass"
  gem.add_development_dependency "compass"
  gem.add_development_dependency "coffee-script"
  gem.add_development_dependency "redcarpet", '~> 2.0'
  gem.add_development_dependency "yui-compressor"
  gem.add_development_dependency "uglifier"
  gem.add_development_dependency "less"
  gem.add_development_dependency "json"
  gem.add_development_dependency "therubyracer"
  gem.add_development_dependency "stylus"
end
