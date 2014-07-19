#!/usr/bin/env rake
require "bundler/gem_tasks"
require "bundler/setup"

desc "run the specs"
task :spec do
  sh "rspec -c -f d spec"
end

task :default => :spec
