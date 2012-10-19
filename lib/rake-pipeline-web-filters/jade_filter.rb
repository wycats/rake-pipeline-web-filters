require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that compiles input files written in Jade
  # to HTML using the Jade compiler
  #
  # Requires node and https://npmjs.org/package/jade by
  # [sudo] npm install jade -g
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.jade"
  #     output "public"
  #
  #     # Compile each Jade file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::JadeFilter
  #   end
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.jade"
  #     output "public"
  #
  #     jade :pretty
  #   end
  class JadeFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies
    
    # @return [Hash] a hash of options to pass to Less
    #   when compiling.
    # @option option :prettify output
    attr_reader :options

    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.(jade)$/, '.html') }
      super(&block)
      @options = options
    end

    def generate_output(inputs, output)

      inputs.each do |input|
        if options[:pretty]
          `jade < #{input.root}/#{input.path} -P --path #{input.root}/#{input.path} > #{output.root}/#{output.path}`
        else
          `jade < #{input.root}/#{input.path} --path #{input.root}/#{input.path} > #{output.root}/#{output.path}`
        end
        out = output.read
        output.write out
      end
    end

  private

    def external_dependencies
      [ ]
    end
    
  end
end
