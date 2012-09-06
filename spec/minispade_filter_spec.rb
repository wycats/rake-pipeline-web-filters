require "json"

describe "MinispadeFilter" do
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  def input_file(contents="var foo = 'bar'; // last-line comment", path="/path/to/input", name="foo.js")
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
      "minispade.register('/path/to/input/foo.js', function() {var foo = 'bar'; // last-line comment\n});"
  end

  it "uses strict if asked" do
    filter = make_filter(input_file, :use_strict => true)
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {\"use strict\";\nvar foo = 'bar'; // last-line comment\n});"
  end

  it "compiles a string if asked" do
    filter = make_filter(input_file, :string => true)
    output_file.body.should ==
      %{minispade.register('/path/to/input/foo.js', "(function() {var foo = 'bar'; // last-line comment\\n})();\\n//@ sourceURL=/path/to/input/foo.js");}
  end

  it "takes a proc to name the module" do
    filter = make_filter(input_file, :module_id_generator => proc { |input| "octopus" })
    output_file.body.should ==
      "minispade.register('octopus', function() {var foo = 'bar'; // last-line comment\n});"
  end

  it "rewrites requires if asked" do
    filter = make_filter(input_file("require('octopus');"), :rewrite_requires => true)
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {minispade.require('octopus');\n});"
  end

  it "rewrites requires if asked even spaces wrap tokens in the require statement" do
    filter = make_filter(input_file("require    ( 'octopus');"), :rewrite_requires => true)
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {minispade.require('octopus');\n});"
  end
  
  it "rewrites requireAll if asked" do
    filter = make_filter(input_file("requireAll('octopus');"), :rewrite_requires => true)
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {minispade.requireAll('octopus');\n});"
  end

  it "rewrites requireAll if asked even spaces wrap tokens in the require statement" do
    filter = make_filter(input_file("requireAll    ( 'octopus');"), :rewrite_requires => true)
    output_file.body.should ==
      "minispade.register('/path/to/input/foo.js', function() {minispade.requireAll('octopus');\n});"
  end
end
