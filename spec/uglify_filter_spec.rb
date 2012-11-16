describe "UglifyFilter" do
  UglifyFilter ||= Rake::Pipeline::Web::Filters::UglifyFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper
  MemoryManifest ||= Rake::Pipeline::SpecHelpers::MemoryManifest

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

  let(:filter_args) { [] }
  let(:filter_block) { nil }

  let(:filter) {
    filter = UglifyFilter.new(*filter_args, &filter_block)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.manifest = MemoryManifest.new
    filter.last_manifest = MemoryManifest.new
    filter.input_files = [input_file("name.js", js_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  }

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  it "generates output" do
    filter.output_files.should == [output_file("name.min.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
    file.body.should == expected_js_output
    file.encoding.should == "UTF-8"
  end

  describe "Skipping" do
    it "skips files ending in .min.js" do
      filter.input_files = [input_file("name.min.js", 'fake-js')]

      filter.output_files.should == [output_file("name.min.js")]

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)

      file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
      file.body.should == 'fake-js'
      file.encoding.should == "UTF-8"
    end

    it "does not count files ending in min.js as preminified" do
      filter.input_files = [input_file("min.js", js_input)]

      filter.output_files.should == [output_file("min.min.js")]

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)

      file = MemoryFileWrapper.files["/path/to/output/min.min.js"]
      file.body.should == expected_js_output
      file.encoding.should == "UTF-8"
    end
  end

  it "translates .js extensions to .min.js by default" do
    filter.output_files.first.path.should == "name.min.js"
  end

  context "with preserve_input option" do
    let(:filter_args) do
      [{ :preserve_input => true }]
    end

    it "should output both the unminified and the minified files" do
      filter.output_files.should == [output_file("name.js"), output_file("name.min.js")]

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)

      file = MemoryFileWrapper.files["/path/to/output/name.js"]
      file.body.should == js_input
      file.encoding.should == "UTF-8"

      file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
      file.body.should == expected_js_output
      file.encoding.should == "UTF-8"
    end
  end

  context "with output name block" do
    let(:filter_block) do
      Proc.new { |input| "octopus" }
    end

    it "customizes output file names" do
      filter.output_files.first.path.should == "octopus"
    end
  end

  context "with Uglify options" do
    let(:filter_args) do
      [{ :beautify => true }]
    end

    it "passes options to the Uglify compressor" do
      filter.input_files = [input_file("name.js", js_input)]
      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)
      file = MemoryFileWrapper.files["/path/to/output/name.min.js"]
      file.body.should == expected_beautiful_js_output
    end
  end
end
