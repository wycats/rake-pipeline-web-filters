module Rake::Pipeline::Web::Filters
  # A filter that transpiles ES6 to either AMD or CommonJS JavaScript.
  class ES6ModuleFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to Transpiler
    attr_reader :options

    # Create an instance of this filter.
    #
    # Possible options:
    # module_id_generator: provide a Proc to convert an input to a
    #                      module identifier (AMD only)
    # Other options are passed along to the RubyES6ModuleTranspiler and then to
    #  the node transpiler. See https://github.com/square/es6-module-transpiler
    #  for more info.
    #
    # @param [Hash] options options (see above)
    # @param [Proc] block the output name generator block
    def initialize(options = {}, &block)
      @module_id_generator = options[:module_id_generator]
      super(&block)
      @options = options
    end

    # The body of the filter. Compile each input file into
    # a ES6 Module Transpiled output file.
    #
    # @param [Array] inputs an Array of FileWrapper objects.
    # @param [FileWrapper] output a FileWrapper object
    def generate_output(inputs, output)
      inputs.each do |input|
        begin
          body = input.read if input.respond_to?(:read)
          local_opts = {}
          if @module_id_generator
            local_opts[:moduleName] = @module_id_generator.call(input)
          end
          opts = @options.merge(local_opts)
          opts.delete(:module_id_generator)
          output.write RubyES6ModuleTranspiler.transpile(body, opts)
        rescue ExecJS::Error => error
          raise error, "Error compiling #{input.path}. #{error.message}"
        end
      end
    end

    def external_dependencies
      [ "ruby_es6_module_transpiler" ]
    end
  end
end
