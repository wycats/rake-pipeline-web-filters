describe "HamlFilter" do
  HamlFilter        ||= Rake::Pipeline::Web::Filters::HamlFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper
  MemoryManifest    ||= Rake::Pipeline::SpecHelpers::MemoryManifest

  let(:haml_input) { <<-HAML }
%h1 Title
%p body
HAML

  let(:haml_html5_input) { <<-HAML }
!!!
%html
  %body
    %h1 Title
    %p body
HAML

  let(:expected_html_output) { <<-HAML }
<h1>Title</h1>
<p>body</p>
HAML

  let(:expected_html5_output) { <<-HAML }
<!DOCTYPE html>
<html>
  <body>
    <h1>Title</h1>
    <p>body</p>
  </body>
</html>
HAML

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter, input_files=nil)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.manifest = MemoryManifest.new
    filter.last_manifest = MemoryManifest.new
    filter.input_files = input_files || [input_file("index.haml", haml_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter HamlFilter.new
    filter.output_files.should == [output_file("index.html")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/index.html"]
    file.body.should == expected_html_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .haml extensions to .html by default" do
      filter = setup_filter HamlFilter.new
      filter.output_files.first.path.should == "index.html"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(HamlFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end

  it "accepts options to pass to the HAML compiler" do
    input_files = [input_file("index.haml", haml_html5_input)]
    filter = setup_filter(HamlFilter.new(:format => :html5), input_files)
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/index.html"]
    file.body.should == expected_html5_output
  end
end
