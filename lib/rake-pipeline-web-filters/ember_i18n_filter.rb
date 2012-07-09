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
    # @param [Hash] options
    #   A hash of options for this filter
    # @option [String] :use_i18n_js
    #   When true, localization information will be output in a format
    #   suitable for i18n-js. If this options is missing data will be
    #   output in the format that Ember.String.loc expects and a method
    #   javascript method EmberI18n.set_locale([string]) is created to
    #   apply a specific set of tranlsations to Ember.STRINGS
    # @note i18n.js is not included, only the translations that 
    #       can be used by i18n.js
    # @see https://github.com/fnando/i18n-js
    # @see http://docs.emberjs.com/symbols/Ember.String.html#method=.loc
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.(yml)$/, '.js') }
      super(&block)
      @options = options
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Generates javascript from i18n yaml files
    # appropriate for Ember#String#loc
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      if @options[:use_i18n_js] == true
        output.write i18n_js_output(inputs)
      else
        output.write ember_i18n_output(inputs)
      end
    end

    private

    def external_dependencies
      [ 'yaml' ]
    end

    def i18n_js_output(inputs)
      "I18n.translations = I18n.translations || {};#{compile_locales_for_i18n_js(inputs)};"
    end

    def compile_locales_for_i18n_js(inputs)
      translations = {}
      inputs.each { |input| translations.merge!(YAML.load(input.read).to_hash) }
      translations.map do |locale_key, locale_value|
        "I18n.translations['#{locale_key}'] = #{locale_value.to_json}"
      end.join(';')
    end

    def ember_i18n_output(inputs)
      "EmberI18n = EmberI18n || {};#{compile_locales_for_ember_i18n(inputs)}"
    end

    def compile_locales_for_ember_i18n(inputs)
      inputs.map do |input|
        parse_ember_i18n_locale(input.read)
      end.join(';')
    end

    def parse_ember_i18n_locale(yml_file)
      dotified = dotify(YAML.load(yml_file))
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

