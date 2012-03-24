#!/usr/bin/env rake
require "bundler/gem_tasks"
require "bundler/setup"

desc "run the specs"
task :spec do
  sh "rspec -cfs spec"
end

task :default => :spec
