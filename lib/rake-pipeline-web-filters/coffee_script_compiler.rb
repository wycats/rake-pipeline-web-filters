module Rake::Pipeline::Web::Filters
  # A filter that compiles CoffeeScript to JavaScript.
  class CoffeeScriptCompiler < Rake::Pipeline::Filter
    # By default, the CoffeeScriptCompiler converts inputs
    # with the extension +.coffee+ to +.js+.
    #
    # @param [Proc] block the output name generator block
    def initialize(&block)
      block ||= proc { |input| input.sub(/\.coffee$/, '.js') }
      super(&block)
    end

    # The body of the filter. Compile each input file into
    # a CoffeeScript compiled output file.
    #
    # @param [Array] inputs an Array of FileWrapper objects.
    # @param [FileWrapper] output a FileWrapper object
    def generate_output(inputs, output)
      require "coffee-script"

      inputs.each do |input|
        output.write CoffeeScript.compile(input)
      end
    end
  end
end
