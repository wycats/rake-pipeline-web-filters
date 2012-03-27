describe "CacheBusterFilter" do
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper
  CacheBusterFilter ||= Rake::Pipeline::Web::Filters::CacheBusterFilter

  let(:content) { "it doesn't matter" }

  let(:input_file) {
    MemoryFileWrapper.new '/path/to/input', 'file.txt', 'UTF-8', content
  }

  let(:output_root) {
    '/path/to/output'
  }

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [ input_file ]
    filter.output_root = output_root
    filter.rake_application = Rake::Application.new
    filter
  end

  describe 'DEFAULT_KEY_GENERATOR' do

    subject { CacheBusterFilter::DEFAULT_KEY_GENERATOR }

    it "returns the MD5 hash of the input's file name and contents" do
      expected = Digest::MD5.new << input_file.path << content
      subject.call(input_file).should == expected
    end

  end

  describe 'with the default cache key strategy' do

    let(:output_file) {
      key = CacheBusterFilter::DEFAULT_KEY_GENERATOR.call(input_file)
      MemoryFileWrapper.new output_root, "file-#{key}.txt", 'UTF-8'
    }

    subject { setup_filter CacheBusterFilter.new }

    it 'outputs to the MD5 hash of the file name and contents' do
      subject.output_files.should == [ output_file ]
    end

    it 'passes file contents through unchanged' do
      tasks = subject.generate_rake_tasks
      tasks.each(&:invoke)
      file = MemoryFileWrapper.files[ output_file.fullpath ]
      file.body.should == content
      file.encoding.should == 'UTF-8'
    end

  end

  describe 'with a custom key strategy' do

    let(:output_file) {
      MemoryFileWrapper.new output_root, 'file-foo.txt', 'UTF-8'
    }

    subject do
      setup_filter(CacheBusterFilter.new() { 'foo' })
    end

    it 'uses the custom key strategy' do
      subject.output_files.should == [ output_file ]
    end

  end

  describe 'for an input file with multiple dots' do
    let(:input_file) {
      MemoryFileWrapper.new '/path/to/input', 'my.text.file.txt', 'UTF-8', content
    }

    let(:output_file) {
      MemoryFileWrapper.new output_root, "my.text.file-foo.txt", 'UTF-8'
    }

    subject { setup_filter(CacheBusterFilter.new() { 'foo' }) }

    it 'appends the busting key to the penultimate part' do
      subject.output_files.should == [ output_file ]
    end
  end

  describe 'for an input file with no dots' do
    let(:input_file) {
      MemoryFileWrapper.new '/path/to/input', 'my_text_file', 'UTF-8', content
    }

    let(:output_file) {
      MemoryFileWrapper.new output_root, "my_text_file-foo", 'UTF-8'
    }

    subject { setup_filter(CacheBusterFilter.new() { 'foo' }) }

    it 'appends the busting key to the end of the filename' do
      subject.output_files.should == [ output_file ]
    end
  end

end
