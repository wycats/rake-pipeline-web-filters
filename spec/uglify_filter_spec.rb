describe "UglifyFilter" do
  UglifyFilter ||= Rake::Pipeline::Web::Filters::UglifyFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:js_input) { <<-HERE }
var name = "Truckasaurus Gates";
console.log(name);
HERE

  let(:expected_js_output) {
    'var name="Truckasaurus Gates";console.log(name);'
  }

  let(:expected_beautiful_js_output) {
    %[var name = "Truckasaurus Gates";\n\nconsole.log(name);;]
  }

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("name.js", js_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter UglifyFilter.new

    filter.output_files.should == [output_file("name.min.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
    file.body.should == expected_js_output
    file.encoding.should == "UTF-8"
  end

  it "skips minified files" do
    filter = setup_filter UglifyFilter.new
    filter.input_files = [input_file("name.min.js", 'fake-js')]

    filter.output_files.should == [output_file("name.min.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
    file.body.should == 'fake-js'
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .js extensions to .min.js by default" do
      filter = setup_filter UglifyFilter.new
      filter.output_files.first.path.should == "name.min.js"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(UglifyFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end

  it "accepts options to pass to the Uglify compressor" do
    filter = setup_filter(UglifyFilter.new(:beautify => true))
    filter.input_files = [input_file("name.js", js_input)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
    file.body.should == expected_beautiful_js_output
  end

end
