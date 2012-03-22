require 'stringio'

describe "NeuterFilter" do
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  def make_input(name, data)
    make_data(name, data)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8")
  end

  def make_data(name, data)
    MemoryFileWrapper.data["/path/to/input/#{name}"] = data
  end

  def make_filter(input_files, *args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    opts[:additional_dependencies] ||= proc{|input| %w(b c) }
    args.push(opts)

    filter = Rake::Pipeline::Web::Filters::NeuterFilter.new(*args)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = input_files
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter.generate_rake_tasks.each(&:invoke)
    filter
  end

  def make_filter_with_inputs(inputs, options={})
    input_file = make_input(inputs[0][0], inputs[0][1])
    inputs[1..-1].each{|input| make_data(input[0], input[1]) }
    make_filter([input_file], "processed", options)
  end

  def capture(*streams)
    streams.map! { |stream| stream.to_s }
    begin
      result = StringIO.new
      streams.each { |stream| eval "$#{stream} = result" }
      yield
    ensure
      streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
    end
    result.string
  end

  after(:each) do
    MemoryFileWrapper.data.clear
  end

  let(:output_files) {
    [
      MemoryFileWrapper.new("/path/to/output", "processed", "BINARY")
    ]
  }

  let(:output_file) {
    MemoryFileWrapper.files["/path/to/output/processed"]
  }

  it "generates basic output" do
    input_file = make_input("contents", "data")
    filter = make_filter([input_file], "processed")

    filter.output_files.should == output_files
    # ConcatFilter forces Binary, not sure if this is right in this case
    output_file.encoding.should == "BINARY"
    output_file.body.should == "data"
  end

  it "orders required files" do
    make_filter_with_inputs([
      ["a", "require('b');\nA"],
      ["b", "require('c');\nB"],
      ["c", "C"]
    ])

    output_file.body.should == "C\n\nB\n\nA"
  end

  it "works with paths" do
    make_filter_with_inputs([
      ["lib/a", "require('lib/b');\nA"],
      ["lib/b", "require('lib/c');\nB"],
      ["lib/c", "C"]
    ], :additional_dependencies => proc{ %w(lib/b lib/c) })

    output_file.body.should == "C\n\nB\n\nA"
  end

  it "should handle circular requires" do
    make_filter_with_inputs([
      ["a", "require('b');\nA"],
      ["b", "require('c');\nB"],
      ["c", "require('a');\nC"]
    ])

    output_file.body.should == "C\n\nB\n\nA"
  end

  it "should not require the same file twice" do
    make_filter_with_inputs([
      ["a", "require('b');\nrequire('c');\nA"],
      ["b", "require('c');\nB"],
      ["c", "require('a');\nC"]
    ])

    output_file.body.should == "C\n\nB\n\nA"
  end

  # Feature not yet supported
  it "does not duplicate files both matched and required"

  describe "config" do
    describe "require_regexp" do
      it "works with minispade format" do
        make_filter_with_inputs([
          ["a", "minispade.require('b');\nA"],
          ["b", "minispade.require('c');\nB"],
          ["c", "C"]
        ], :require_regexp => %r{^\s*minispade\.require\(['"]([^'"]*)['"]\);?\s*})

        output_file.body.should == "C\n\nB\n\nA"
      end

      it "works with sprockets format" do
        make_filter_with_inputs([
          ["a", "//= require b\nA"],
          ["b", "//= require c\nB"],
          ["c", "C"]
        ], :require_regexp => %r{^//= require (\S+)\s*})

        output_file.body.should == "C\n\nB\n\nA"
      end
    end

    describe "path_transform" do
      it "converts paths" do
        make_filter_with_inputs([
          ["lib/a.js", "require('b');\nA"],
          ["lib/b.js", "require('c');\nB"],
          ["lib/c.js", "C"]
        ], :path_transform => proc{|path| "lib/#{path}.js" },
           :additional_dependencies => proc{ %w(lib/b.js lib/c.js) })

        output_file.body.should == "C\n\nB\n\nA"
      end
    end

    describe "closure_wrap" do
      it "wraps in a javascript closure" do
        make_filter_with_inputs([
          ["a", "require('b');\nA"],
          ["b", "require('c');\nB"],
          ["c", "C"]
        ], :closure_wrap => true)

        output_file.body.should == "(function() {\nC\n})();\n\n\n\n(function() {\nB\n})();\n\n\n\n(function() {\nA\n})();\n\n"
      end

      # Not yet supported
      it "allows other wrapper types"
    end

    describe "filename_comment" do
      it "shows a comment with the filename" do
        make_filter_with_inputs([
          ["a", "require('b');\nA"],
          ["b", "require('c');\nB"],
          ["c", "C"],
        ], :filename_comment => proc{|input| "/* #{input.fullpath} */" })

        output_file.body.should == "/* /path/to/input/c */\nC\n\n/* /path/to/input/b */\nB\n\n/* /path/to/input/a */\nA"
      end
    end

    describe "additional_dependencies" do
      it "warns if required file is not contained" do
        output = capture(:stderr) do
          make_filter_with_inputs([
            ["d", "require('e');\nD"],
            ["e", "require('f');\nE"],
            ["f", "F"]
          ])
        end

        output.should include("Included '/path/to/input/e', which is not listed in :additional_dependencies. The pipeline may not invalidate properly.")
        output.should include("Included '/path/to/input/f', which is not listed in :additional_dependencies. The pipeline may not invalidate properly.")
      end

      it "does not warn if full paths are provided" do
        output = capture(:stderr) do
          make_filter_with_inputs([
            ["d", "require('e');\nD"],
            ["e", "require('f');\nE"],
            ["f", "F"]
          ], :additional_dependencies => proc{ %w(/path/to/input/e /path/to/input/f) })
        end

        output.should == ""
      end
    end
  end
end
