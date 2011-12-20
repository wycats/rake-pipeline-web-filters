describe "YUIJavaScriptCompressor" do
  YUICompressor = Rake::Pipeline::Web::Filters::YUIJavaScriptCompressor

  JS_INPUT = <<-HERE
var name = "Truckasaurus Gates";
console.log(name);
HERE

  EXPECTED_JS_OUTPUT = 'var name="Truckasaurus Gates";console.log(name);'

  EXPECTED_LINEBREAK_JS_OUTPUT = %[var name="Truckasaurus Gates";\nconsole.log(name);]

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("name.js", JS_INPUT)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter YUICompressor.new

    filter.output_files.should == [output_file("name.min.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
    file.body.should == EXPECTED_JS_OUTPUT
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .js extensions to .min.js by default" do
      filter = setup_filter YUICompressor.new
      filter.output_files.first.path.should == "name.min.js"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(YUICompressor.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end

  it "accepts options to pass to the YUI compressor" do
    filter = setup_filter(YUICompressor.new(:line_break => 0))
    filter.input_files = [input_file("name.js", JS_INPUT)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
    file.body.should == EXPECTED_LINEBREAK_JS_OUTPUT
  end

end
