describe "JadeFilter" do
  JadeFilter ||= Rake::Pipeline::Web::Filters::JadeFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:jade_input) {"""
!!! 5
html
  head
    title Hello
  body
    h1 Hello
"""
}

  let(:expected_html_output) {"""<!DOCTYPE html><html><head><title>Hello</title></head><body><h1>Hello</h1></body></html>"""
}

let(:expected_prettified_html_output) {"""\
<!DOCTYPE html>
<html>
  <head>
    <title>Hello</title>
  </head>
  <body>
    <h1>Hello</h1>
  </body>
</html>"""
}

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter, input=jade_input)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("index.jade", input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter JadeFilter.new

    filter.output_files.should == [output_file("index.html")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/index.html"]
    file.body.should == expected_html_output
    file.encoding.should == "UTF-8"
  end

  it "prettifies output" do
    filter = setup_filter JadeFilter.new :pretty => true

    filter.output_files.should == [output_file("index.html")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/index.html"]
    file.body.should == expected_prettified_html_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .jade extensions to .html by default" do
      filter = setup_filter JadeFilter.new
      filter.output_files.first.path.should == "index.html"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(JadeFilter.new { |input| "hbs" })
      filter.output_files.first.path.should == "hbs"
    end
  end
end
