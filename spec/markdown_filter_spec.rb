describe "MarkdownFilter" do
  MarkdownFilter ||= Rake::Pipeline::Web::Filters::MarkdownFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:markdown_input) { <<-MARKDOWN }
## This is an H2

Some *important* text. It might have a link: http://foo.com/

    Some code

That's all.
MARKDOWN

  let(:expected_html_output) { <<-HTML }
<h2>This is an H2</h2>

<p>Some <em>important</em> text. It might have a link: http://foo.com/</p>

<pre><code>Some code
</code></pre>

<p>That&#39;s all.</p>
HTML

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("page.md", markdown_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter MarkdownFilter.new

    filter.output_files.should == [output_file("page.html")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/page.html"]
    file.body.should == expected_html_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .md extensions to .html by default" do
      filter = setup_filter MarkdownFilter.new
      filter.output_files.first.path.should == "page.html"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(MarkdownFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end

  it "passes options to the Markdown compiler" do
    filter = setup_filter(MarkdownFilter.new(:autolink => true))
    filter.input_files = [input_file("page.md", markdown_input)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/page.html"]
    file.body.should =~ %r{<a href="http://foo\.com/">}
  end

  it "accepts a :compiler option" do
    filter = setup_filter(MarkdownFilter.new(:compiler => proc { |text, options| text }))
    filter.input_files = [input_file("page.md", markdown_input)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/page.html"]
    file.body.should == markdown_input
  end

end

