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
  #     filter Rake::Pipeline::Web::Filters::MinispadeFilter
  #   end
  class MinispadeFilter < Rake::Pipeline::Filter

    # @param [Hash] options
    # @option options [Boolean] :use_strict Whether to add "use strict" to
    #   each outputted function; defaults to false.
    # @option options [Proc] :module_id_generator a proc to use to generate
    #   the minispade module id.
    # @option options [Boolean] :rewrite_requires If true, change calls to
    #   +require+ in the source to +minispade.require+.
    # @option options [Boolean] :string If true, compiles the output as
    #   a String instead of a closure. This means that @sourceURL can be
    #   appended for good stack traces and debugging.
    def initialize(options = {})
      super()
      @use_strict = options[:use_strict]
      @module_id_generator = options[:module_id_generator] ||
        proc { |input| input.fullpath.sub(Dir.pwd, '') }
      @resolve_relative_references = options[:resolve_relative_references]
      @rewrite_requires = options[:rewrite_requires]
      @string_module = options[:string]
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
        module_id = @module_id_generator.call(input)

        code = resolve_relative_references(code, module_id) if @resolve_relative_references
        code.gsub!(%r{^\s*require\(}, 'minispade.require(') if @rewrite_requires
        code = %["use strict";\n] + code if @use_strict

        if @string_module
          contents = %{#{code}\n//@ sourceURL=#{module_id}}.to_json
        else
          contents = "function() {\n#{code}\n}"
        end
        ret = "minispade.register('#{module_id}', #{contents});\n"
        output.write ret
      end
    end
    
    def resolve_relative_references(code, module_id)
      this_dir = File.dirname(module_id)
      this_dir = (this_dir == '.')? "#{module_id}/": "#{this_dir}/"
      code.gsub!(%r{^\s*require\s*\(\s*\'\.\/}, "require('#{this_dir}")
      code.gsub!(%r{^\s*require\s*\(\s*\'\.\.\/}, "require('#{this_dir}../")
      code.gsub!(%r{^\s*require\s*\(\s*\"\.\/}, %Q|require("#{this_dir}|)
      code.gsub!(%r{^\s*require\s*\(\s*\"\.\.\/}, %Q|require("#{this_dir}../|)
      code
    end
  end
end
