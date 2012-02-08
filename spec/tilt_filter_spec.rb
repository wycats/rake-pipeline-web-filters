describe "TiltFilter" do
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:input_files) {
    [
      MemoryFileWrapper.new("/path/to/input", "foo.erb", "UTF-8", "<%= 'foo' %>\n"),
      MemoryFileWrapper.new("/path/to/input", "bar.str", "UTF-8", '#{ "bar" }')
    ]
  }

  let(:output_files) {
    [
      MemoryFileWrapper.new("/path/to/output", "foo.txt", "UTF-8"),
      MemoryFileWrapper.new("/path/to/output", "bar.txt", "UTF-8")
    ]
  }

  def make_filter(*args)
    filter = Rake::Pipeline::Web::Filters::TiltFilter.new(*args) do |input|
      input.sub(/\.(erb|str)$/, '.txt')
    end
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

    file = MemoryFileWrapper.files["/path/to/output/foo.txt"]
    file.body.should == "foo"
    file.encoding.should == "UTF-8"

    file = MemoryFileWrapper.files["/path/to/output/bar.txt"]
    file.body.should == "bar"
    file.encoding.should == "UTF-8"
  end

  it "accepts options to pass to the template class" do
    # :trim => '' should tell ERB not to trim newlines
    filter = make_filter(:trim => '')

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/foo.txt"]
    file.body.should == "foo\n"
  end

  describe 'with a rendering context' do

    let(:input_files) do
      [
        MemoryFileWrapper.new("/path/to/input", "foo.erb", "UTF-8", "<%= foo %>"),
      ]
    end

    let(:context) do
      context = Class.new do
        def foo; 'foo'; end
      end.new
    end

    it 'uses the context' do
      filter = make_filter({}, context)

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)
      file = MemoryFileWrapper.files["/path/to/output/foo.txt"]
      file.body.should == "foo"
    end
  end
end
