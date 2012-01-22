describe "MinispadeFilter" do

  def input_file(contents="var foo = 'bar';", path="/path/to/input", name="foo.js")
    MemoryFileWrapper.new(path, name, "UTF-8", contents)
  end

  let(:output_files) {
    [
      MemoryFileWrapper.new("/path/to/output", "foo.js", "UTF-8")
    ]
  }

  let(:output_file) {
    MemoryFileWrapper.files["/path/to/output/foo.js"]
  }

  def make_filter(input_file, *args)
    filter = Rake::Pipeline::Web::Filters::MinispadeFilter.new(*args)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter.generate_rake_tasks.each(&:invoke)
    filter
  end

  it "generates output" do
    filter = make_filter(input_file)
    filter.output_files.should == output_files
    output_file.encoding.should == "UTF-8"
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {\nvar foo = 'bar';\n});\n"
  end

  it "uses strict if asked" do
    filter = make_filter(input_file, :use_strict => true)
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {\n\"use strict\";\nvar foo = 'bar';\n});\n"
  end

  it "compiles a string if asked" do
    filter = make_filter(input_file, :string => true)
    output_file.body.should ==
      %{minispade.register('/path/to/input/foo.js', "var foo = 'bar';\\n//@ sourceURL=/path/to/input/foo.js");\n}
  end

  it "takes a proc to name the module" do
    filter = make_filter(input_file, :module_id_generator => proc { |input| "octopus" })
    output_file.body.should ==
      "minispade.register('octopus', function() {\nvar foo = 'bar';\n});\n"
  end

  it "resolves relative references if asked" do
    filter = make_filter(input_file("require('./squid');\nrequire('eel/electric');\nrequire('../whales/humpback')"), :resolve_relative_references => true)
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {\nrequire('/path/to/input/squid');\nrequire('eel/electric');\nrequire('/path/to/input/../whales/humpback')\n});\n"
  end

  it "rewrites requires if asked" do
    filter = make_filter(input_file("require('octopus');"), :rewrite_requires => true)
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {\nminispade.require('octopus');\n});\n"
  end
end
