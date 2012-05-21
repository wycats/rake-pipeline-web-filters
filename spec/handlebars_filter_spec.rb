describe "HandlebarsFilter" do
  HandlebarsFilter ||= Rake::Pipeline::Web::Filters::HandlebarsFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:handlebars_input) {
    '<h1 class="title">{{title}}</h1>'
  }

  let(:expected_output) {
    "Ember.TEMPLATES['test']=Ember.Handlebars.compile(\"<h1 class=\\\"title\\\">{{title}}</h1>\");"
  }

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter, input_filename = "test.handlebars")
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file(input_filename, handlebars_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter HandlebarsFilter.new

    filter.output_files.should == [output_file("test.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/test.js"]
    file.body.should == expected_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .handlebars extensions to .js by default" do
      filter = setup_filter HandlebarsFilter.new, "test.handlebars"
      filter.output_files.first.path.should == "test.js"
    end

    it "translates .hbs extensions to .js by default" do
      filter = setup_filter HandlebarsFilter.new, "test.hbs"
      filter.output_files.first.path.should == "test.js"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(HandlebarsFilter.new { |input| "squid" })
      filter.output_files.first.path.should == "squid"
    end
  end

  describe "options" do
    it "should allow an option to name the key" do
      filter = setup_filter(HandlebarsFilter.new(:key_name_proc => proc { |input| "new_name_key" }))
        
      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)

      file = MemoryFileWrapper.files["/path/to/output/test.js"]
      file.body.should =~ /^Ember\.TEMPLATES\['new_name_key'\]/
    end
  end
end
