describe "MarkdownCompiler" do
  MemoryFileWrapper = Rake::Pipeline::SpecHelpers::MemoryFileWrapper
  MarkdownCompiler = Rake::Pipeline::Web::Filters::MarkdownCompiler

  MARKDOWN_INPUT = <<-MARKDOWN
## This is an H2

Some *important* text. It might have a link: http://foo.com/

    Some code

That's all.
MARKDOWN

  EXPECTED_HTML_OUTPUT = <<-HTML
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
    filter.input_files = [input_file("page.md", MARKDOWN_INPUT)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter MarkdownCompiler.new

    filter.output_files.should == [output_file("page.html")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/page.html"]
    file.body.should == EXPECTED_HTML_OUTPUT
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .md extensions to .html by default" do
      filter = setup_filter MarkdownCompiler.new
      filter.output_files.first.path.should == "page.html"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(MarkdownCompiler.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end

  it "passes options to the Markdown compiler" do
    filter = setup_filter(MarkdownCompiler.new(:autolink => true))
    filter.input_files = [input_file("page.md", MARKDOWN_INPUT)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/page.html"]
    file.body.should =~ %r{<a href="http://foo\.com/">}
  end

  it "accepts a :compiler option" do
    filter = setup_filter(MarkdownCompiler.new(:compiler => proc { |text, options| text }))
    filter.input_files = [input_file("page.md", MARKDOWN_INPUT)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/page.html"]
    file.body.should == MARKDOWN_INPUT
  end

end

