module Rake::Pipeline::Web::Filters

  class NeuterBatch
    def initialize(config, known_files)
      @config = config || {}
      @known_files = known_files
      @required = []
    end

    def file_wrapper(klass, *args)
      file = klass.new(*args)
      file.extend NeuterWrapper
      file.batch(self)
      file
    end

    def required(req)
      unless @known_files.include?(req)
        warn "Included '#{req}', which is not listed in :additional_dependencies. The pipeline may not invalidate properly."
      end
      @required << req
    end

    def required?(req)
      @required.include?(req)
    end

    def strip_requires(source)
      requires = []
      regexp = @config[:require_regexp] || %r{^\s*require\(['"]([^'"]*)['"]\);?\s*}
      # FIXME: This $1 may not be reliable with other regexps
      source.gsub!(regexp){ requires << $1; '' }
      requires
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
      @batch.required(fullpath)
    end

    def read
      source = super

      required_files = @batch.strip_requires(source).map do |req|
        req_path = @batch.transform_path(req, self)
        if req_path && !@batch.required?(File.expand_path(req_path, root))
          @batch.file_wrapper(self.class, root, req_path, encoding).read
        else
          nil
        end
      end.compact

      file = @batch.filename_comment(self) + @batch.closure_wrap(source)

      (required_files << file).join("\n\n")
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
        known_files = [input.fullpath] + additional_dependencies(input)
        batch = NeuterBatch.new(@config, known_files)
        file = batch.file_wrapper(file_wrapper_class, input.root, input.path, input.encoding)
        output.write file.read
      end
    end

    def additional_dependencies(input)
      method = @config[:additional_dependencies]
      method ? method.call(input).map{|p| File.expand_path(p, input.root) } : []
    end
  end
end
