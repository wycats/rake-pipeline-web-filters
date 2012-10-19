module Rake::Pipeline::Web::Filters
  # A filter that converts handlebars templates to javascript
  # and stores them in a defined variable.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "**/*.handlebars"
  #     output "public"
  #
  #     # Compile each handlebars file to JS
  #     handlebars
  #   end
  class HandlebarsFilter < Rake::Pipeline::Filter

    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options for generate_output
    attr_reader :options

    # @param [Hash] options
    #   options to pass to the output generator
    # @option options [String] :target
    #   the variable to store templates in
    # @option options [Proc] :wrapper_proc
    #   the js to wrap template contents in
    # @option options [Proc] :compiler_proc
    #   processes the source. Return value is passed to wrapper_proc
    # @option options [Proc] :key_name_proc
    #   used to determine the template name
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={},&block)
      # Convert .handlebars file extensions to .js
      block ||= proc { |input| input.sub(/\.handlebars|\.hbs$/, '.js') }
      super(&block)
      @options = {
          :target =>'Ember.TEMPLATES',
          :wrapper_proc => proc { |source| "Ember.Handlebars.compile(#{source});" },
          :key_name_proc => proc { |input| File.basename(input.path, File.extname(input.path)) },
          :compiler_proc => proc { |source| source },
        }.merge(options)
    end

    def generate_output(inputs, output)

      inputs.each do |input|
        # The name of the template is the filename, sans extension
        name = options[:key_name_proc].call(input)

        # Read the file and escape it so it's a valid JS string
        source = options[:compiler_proc].call(input.read.to_json)

        # Write out a JS file, saved to target, wrapped in compiler
        output.write "#{options[:target]}['#{name}']=#{options[:wrapper_proc].call(source)}"
      end
    end

    private 

    def external_dependencies
      [ 'json' ]
    end
  end
end
