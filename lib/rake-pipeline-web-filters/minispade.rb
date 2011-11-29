module Rake::Pipeline::Web::Filters
  # A filter that wraps JavaScript files in a minispade.register closure
  # for use in minispade.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     # Wrap each JS file in a minispade.register closure.
  #     filter Rake::Pipeleine::Web::Filters::MinispadeFilter
  #   end
  class MinispadeFilter < Rake::Pipeline::Filter

    # @param [Hash] options
    # @option options [Boolean] :use_strict Whether to add "use strict" to
    #   each outputted function; defaults to false.
    # @option options [Proc] :module_id_generator a proc to use to generate
    #   the minispade module id.
    def initialize(options = {})
      super()
      @use_strict = !!options[:use_strict]
      @module_id_generator = options[:module_id_generator] ||
        proc { |input| input.fullpath.sub(Dir.pwd, '') }
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Wraps each input file in a minispade.register
    # closure.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        code = input.read
        code = '"use strict"; ' + code if @use_strict
        function = "function() { #{code} }"
        ret = "minispade.register('#{@module_id_generator.call(input)}',#{function});"
        output.write ret
      end
    end
  end
end
