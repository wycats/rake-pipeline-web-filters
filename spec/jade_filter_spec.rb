describe "JadeFilter" do
  JadeFilter ||= Rake::Pipeline::Web::Filters::JadeFilter
  MemoryManifest ||= Rake::Pipeline::SpecHelpers::MemoryManifest

  let(:jade_input) {
    """
!!! 5
html
  head
    title Hello
  body
    h1 Hello
"""
  }

  let(:expected_html_output) {
    """<!DOCTYPE html><html><head><title>Hello</title></head><body><h1>Hello</h1></body></html>"""
  }

  let(:expected_prettified_html_output) {
    """\
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

  let(:input_root) { File.expand_path('./input') }
  let(:input_path) { 'index.jade' }

  let(:input_file) {
    mkdir_p input_root
    File.open(File.join(input_root, input_path), 'w+:UTF-8') {|file| file << jade_input }
    Rake::Pipeline::FileWrapper.new(input_root, input_path, "UTF-8")
  }

  let(:output_root) { File.expand_path('./output') }
  let(:output_path) { 'index.html' }

  let(:output_file) {
    Rake::Pipeline::FileWrapper.new(output_root, output_path, "UTF-8")
  }

  def setup_filter(filter, input=jade_input)
    filter.manifest = MemoryManifest.new
    filter.last_manifest = MemoryManifest.new
    filter.input_files = [input_file]
    filter.output_root = output_root
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter JadeFilter.new
    filter.output_files.should == [output_file]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    output_file.read.should == expected_html_output
    output_file.encoding.should == "UTF-8"
  end

  it "prettifies output" do
    filter = setup_filter JadeFilter.new :pretty => true

    filter.output_files.should == [output_file]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    output_file.read.should == expected_prettified_html_output
    output_file.encoding.should == "UTF-8"
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