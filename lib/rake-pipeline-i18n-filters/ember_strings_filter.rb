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
  #     filter Rake::Pipeline::Web::Filters::EmberI18nFilter
  #   end
  #
  class EmberStringsFilter < Rake::Pipeline::Filter
    # @param [Hash] options
    #   A hash of options for this filter
    # @option [String] :use_i18n_js
    #   When true, localization information will be output in a format
    #   suitable for i18n-js. If this option is missing data will be
    #   output in the format that Ember.String.loc expects.
    # @note If you are using Ember.String.loc be sure to set
    #      Ember.STRINGS = EmberI18n['locale'];
    # where 'locale' is the locale you have parsed and want to render.
    # @see https://github.com/fnando/i18n-js
    # @see http://docs.emberjs.com/symbols/Ember.String.html#method=.loc
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(&block)
      block ||= proc { |input| input.sub(/\.(yml)$/, '.js') }
      super(&block)
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Generates javascript from i18n yaml files
    # appropriate for Ember#String#loc or i18n-js
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
        output.write ember_i18n_output(inputs)
    end

    private

    def external_dependencies
      [ 'yaml' ]
    end

    def ember_i18n_output(inputs)
      "EmberI18n = EmberI18n || {};#{compile_locales_for_ember_i18n(inputs)}"
    end

    def compile_locales_for_ember_i18n(inputs)
      output_hash = {}
      inputs.map do |input|
        output_hash.deep_merge! YAML.load(input.read)
      end
      parse_ember_i18n_locales(output_hash)
    end

    def parse_ember_i18n_locales(output_hash)
      dotified = dotify(output_hash)
      dotified.map do |locale_key, locale_value|
        locale_strings = locale_value.map do |entry_key, entry_value|
          "'#{entry_key}' : '#{entry_value}'"
        end.join(',')
        "EmberI18n['#{locale_key}'] = { #{locale_strings} };"
      end.join('')
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
