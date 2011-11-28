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

  def make_filter(*args)
    filter = Rake::Pipeline::Web::Filters::MinispadeFilter.new(*args)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = input_files
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = make_filter

    filter.output_files.should == output_files

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/foo.js"]
    file.body.should == "minispade.register('/path/to/input/foo.js',function() { var foo = 'bar'; });"
    file.encoding.should == "UTF-8"
  end
end
