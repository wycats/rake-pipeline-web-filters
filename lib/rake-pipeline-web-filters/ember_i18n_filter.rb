# encoding: UTF-8
require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
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
  #     filter Rake::Pipeline::Web::Filters::EmberI18nFilter
  #   end
  #
  class EmberI18nFilter < Rake::Pipeline::Filter

    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(&block)
      block ||= proc { |input| input.sub(/\.(yml)$/, '.js') }
      super(&block)
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Generates javascript from i18n yaml files
    # appropriate for Ember#String#loc
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output, options={})
      
      # setup the global I18n holder 
      # ?? namespace this ??
      output.write <<JS
if(I18n == undefined) {
 var I18n = {
       set_locale : function(locale) {
                      Ember.STRINGS = this[locale]
                    }
       }
};
JS

      inputs.each do |input|
        output.write compile(input)

      end
    end

    private

    def external_dependencies
      [ 'yaml' ]
    end

    def compile(yml_file)
      parse_locale(yml_file)
    end

    def parse_locale(yml_file)
      yaml = YAML.load(yml_file.body)
      dotified_yaml = dotify(yaml)
      dotified_yaml.map do |locale_key, locale_value|
        locale_strings = locale_value.map do |entry_key,entry_value| 
          "'#{entry_key}' : '#{entry_value}'"
        end.join(',')
        "I18n['#{locale_key}'] = { #{locale_strings} }"
      end.join(';')
    end

    def dotify(source, target={}, path=nil)
      prefix = "#{path}." if path
      if source.is_a?(Hash)
        source.each do |key, value|
          dotify(value, target, "#{prefix}#{key}")
        end
      else
        target[path.split('.')[1..-1].join('.')] = source
      end
    end
  end
end

