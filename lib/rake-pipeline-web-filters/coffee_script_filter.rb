module Rake::Pipeline::Web::Filters
  # A filter that compiles CoffeeScript to JavaScript.
  class CoffeeScriptFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to CoffeeScript when
    #   rendering.
    attr_reader :options

    # By default, the CoffeeScriptFilter converts inputs
    # with the extension +.coffee+ to +.js+.
    #
    # @param [Hash] options options to pass to the CoffeeScript
    #   compiler.
    # @param [Proc] block the output name generator block
    def initialize(options = {}, &block)
      block ||= proc { |input| input.sub(/\.coffee$/, '.js') }
      super(&block)
      @options = options
    end

    # The body of the filter. Compile each input file into
    # a CoffeeScript compiled output file.
    #
    # @param [Array] inputs an Array of FileWrapper objects.
    # @param [FileWrapper] output a FileWrapper object
    def generate_output(inputs, output)
      inputs.each do |input|
        begin
          output.write CoffeeScript.compile(input, options)
        rescue ExecJS::Error => error
          raise error, "Error compiling #{input.path}. #{error.message}"
        end
      end
    end

    def external_dependencies
      [ "coffee-script" ]
    end
  end
end
