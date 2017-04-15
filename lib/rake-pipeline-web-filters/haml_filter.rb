require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters

  class HamlFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    attr_reader :options

    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.haml$/, '.html') }
      super(&block)
      @options = options
    end

    def generate_output(inputs, output)
      inputs.each do |input|
        output.write Haml::Engine.new(input.read, options).render
      end
    end

    private

    def external_dependencies
      [ 'haml' ]
    end
  end

end
