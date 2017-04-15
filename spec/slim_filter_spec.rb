describe "SlimFilter" do
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper
  MemoryManifest ||= Rake::Pipeline::SpecHelpers::MemoryManifest

  let(:slim_input) { <<-SLIM }
doctype html
html
  head
    title Slim Sample
  body
    p I love slim!
SLIM

  let (:slim_output) do
    "<!DOCTYPE html><html><head><title>Slim Sample</title></head><body><p>I love slim!</p></body></html>"
  end

  let(:slim_rb_input) { <<-SLIM }
- [0,1,2].each do |i|
  li= i
SLIM

  let(:slim_rb_output) { "<li>0</li><li>1</li><li>2</li>" }

let(:input_files) {
  [
    MemoryFileWrapper.new("/path/to/input", "foo.slim", "UTF-8", slim_input),
    MemoryFileWrapper.new("/path/to/input", "bar.slim", "UTF-8", slim_rb_input)
  ]
}

let(:output_files) {
  [
    MemoryFileWrapper.new("/path/to/output", "foo.html", "UTF-8"),
    MemoryFileWrapper.new("/path/to/output", "bar.html", "UTF-8")
  ]
}

  def make_filter(*args)
    filter = Rake::Pipeline::Web::Filters::SlimFilter.new(*args) do |input|
      input.sub(/\.slim$/, '.html')
    end
    filter.file_wrapper_class = MemoryFileWrapper
    filter.manifest = MemoryManifest.new
    filter.last_manifest = MemoryManifest.new
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

    file = MemoryFileWrapper.files["/path/to/output/foo.html"]
    file.body.should == slim_output
    file.encoding.should == "UTF-8"

    file = MemoryFileWrapper.files["/path/to/output/bar.html"]
    file.body.should == slim_rb_output
    file.encoding.should == "UTF-8"
  end

  it "accepts options to pass to the template class" do
    # :pretty => true should indent html for pretty debugging
    filter = make_filter(:pretty => true)

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/foo.html"]
    # body should contain line breaks, and stripping out line breaks & indents
    # should produce the original output
    file.body.should include "\n  "
    file.body.gsub(/\n\s*/, '').should == slim_output
  end

  describe 'with a rendering context' do

    let(:input_files) do
      [
        MemoryFileWrapper.new("/path/to/input", "foo.slim", "UTF-8", "b= foo"),
      ]
    end

    let(:context) do
      context = Class.new do
        def foo; 'bar'; end
      end.new
    end

    it 'uses the context' do
      filter = make_filter({}, context)

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)
      file = MemoryFileWrapper.files["/path/to/output/foo.html"]
      file.body.should == "<b>bar</b>"
    end
  end
end
