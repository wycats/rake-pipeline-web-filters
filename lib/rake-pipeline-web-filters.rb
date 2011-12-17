require "rake-pipeline"

module Rake
  class Pipeline
    module Web
      module Filters
      end
    end
  end
end

Dir[File.expand_path('../rake-pipeline-web-filters/**/*.rb', __FILE__)].each do |f|
  require f
end

