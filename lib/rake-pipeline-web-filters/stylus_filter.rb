require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that compiles input files written in Stylus
  # to CSS using the Stylus compiler
  #
  # Requires http://rubygems.org/gems/stylus
  #
  # You will need the `node` command on your runtime
  # for this to work. See https://github.com/lucasmazza/ruby-stylus
  # for more information.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.styl"
  #     output "public"
  #
  #     # Compile each Stylus file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::StylusFilter
  #   end
  class StylusFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies
    
    attr_reader :options

    # @param [Hash] options options to pass to Stylus
    # @option options [Array] :use Plugins to import from Node
    # @option options [Boolean] :debug Output debug info
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.(styl)$/, '.css') }
      super(&block)
      @options = options
    end

    def generate_output(inputs, output)
      options.each do |key, value|
        if key == :use
          Stylus.send key, *value
          next
        end
        Stylus.send "#{key}=", value
      end
      inputs.each do |input|
        output.write Stylus.compile(input.read)
      end
    end

  private

    def external_dependencies
      [ 'stylus' ]
    end
    
  end
end
