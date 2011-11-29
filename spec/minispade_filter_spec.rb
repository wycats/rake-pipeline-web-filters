describe "MinispadeFilter" do
  MemoryFileWrapper = Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:input_files) {
    [
      MemoryFileWrapper.new("/path/to/input", "foo.js", "UTF-8", "var foo = 'bar';")
    ]
  }

  let(:output_files) {
    [
      MemoryFileWrapper.new("/path/to/output", "foo.js", "UTF-8")
    ]
  }

  let(:output_file) {
    MemoryFileWrapper.files["/path/to/output/foo.js"]
  }

  def make_filter(*args)
    filter = Rake::Pipeline::Web::Filters::MinispadeFilter.new(*args)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = input_files
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter.generate_rake_tasks.each(&:invoke)
    filter
  end

  it "generates output" do
    filter = make_filter

    filter.output_files.should == output_files
    output_file.body.should == "minispade.register('/path/to/input/foo.js',function() { var foo = 'bar'; });"
    output_file.encoding.should == "UTF-8"
  end

  it "uses strict if asked" do
    filter = make_filter(:use_strict => true)
    output_file.body.should == "minispade.register('/path/to/input/foo.js',function() { \"use strict\"; var foo = 'bar'; });"
  end

  it "takes a proc to name the module" do
    filter = make_filter(:module_id_generator => proc { |input| "octopus" })
    output_file.body.should == "minispade.register('octopus',function() { var foo = 'bar'; });"
  end
end
