require 'rake-pipeline-i18n-filters/filter_with_dependencies'

module Rake::Pipeline::I18n::Filters
  # A filter that compiles locale yml files into javascript
  # appropriate for use by Ember#String#loc
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "config/locales", "**/*.yml"
  #     output "public"
  #
  #     # Compile each .yml file under the config/locales
  #     # directory.
  #     filter Rake::Pipeline::I18n::Filters::I18nJSFilter
  #   end
  #
  class I18nJsFilter < Rake::Pipeline::Filter
    # @see https://github.com/fnando/i18n-js
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(&block)
      block ||= proc { |input| input.sub(/\.(yml)$/, '.js') }
      super(&block)
    end
 
    # Implement the {#generate_output} method required by
    # the {Filter} API. Generates javascript from i18n yaml files
    # appropriate for i18n-js
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      js_dec = 'I18n.translations = I18n.translations || {};' 
      output_hash = {}
      inputs.each do |input|
        output_hash.deep_merge! YAML.load(input.read)
      end  
      output.write "#{js_dec}\nI18n.translations = #{output_hash.to_json};"
    end

    private

    def external_dependencies
      [ 'yaml' ]
    end

  end
end
