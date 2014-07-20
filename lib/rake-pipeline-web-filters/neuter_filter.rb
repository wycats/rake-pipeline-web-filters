module Rake::Pipeline::Web::Filters

  class NeuterBatch
    def initialize(config)
      @config = config || {}
      @required = []
    end

    def file_wrapper(klass, *args)
      file = klass.new(*args)
      file.extend NeuterWrapper
      file.batch(self)
      file
    end

    def required(req)
      @required << req
    end

    def required?(req)
      @required.include?(req)
    end

    def regexp
      @config[:require_regexp] || %r{^\s*require\(['"]([^'"]*)['"]\);?\s*}
    end

    def transform_path(path, input)
      @config[:path_transform] ? @config[:path_transform].call(path, input) : path
    end

    def closure_wrap(source)
      @config[:closure_wrap] ? "(function() {\n#{source}\n})();\n\n" : source
    end

    def filename_comment(input)
      @config[:filename_comment] ? @config[:filename_comment].call(input) + "\n" : ""
    end
  end

  module NeuterWrapper
    def batch(batch)
      @batch = batch
    end

    def neuter
      return if required?

      @batch.required fullpath

      files_to_inject = dependencies.reject(&:required?)
      dependent_content = files_to_inject.map(&:neuter).compact

      this_file = @batch.filename_comment(self) + @batch.closure_wrap(stripped_source)

      [dependent_content, this_file].reject(&:empty?).join("\n\n")
    end

    def required?
      @batch.required? fullpath
    end

    def requires
      read.scan(@batch.regexp).flatten
    end

    def dependencies
      requires.map do |req|
        req_path = @batch.transform_path(req, self)
        @batch.file_wrapper(self.class, root, req_path, encoding)
      end
    end

    def stripped_source
      read.gsub @batch.regexp, ''
    end
  end

  # A filter that takes files with requires and collapses them into a single
  # file without requires.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     filter Rake::Pipeline::Web::Filters::NeuterFilter, "neutered.js"
  #   end
  class NeuterFilter < Rake::Pipeline::ConcatFilter
    def initialize(string=nil, config={}, &block)
      if string.is_a?(Hash)
        config = string
        string = nil
      end

      @config = config

      super(string, &block)
    end

    def generate_output(inputs, output)
      inputs.each do |input|
        batch = NeuterBatch.new @config
        file = batch.file_wrapper(file_wrapper_class, input.root, input.path, input.encoding)
        output.write file.neuter
      end
    end

    def additional_dependencies(input)
      dependent_files(input).map(&:fullpath)
    end

    def dependent_files(input)
      batch = NeuterBatch.new @config
      wrapper = batch.file_wrapper(file_wrapper_class, input.root, input.path, input.encoding)
      wrapper.dependencies
    end
  end
end
