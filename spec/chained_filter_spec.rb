describe "ChainedFilter" do
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper
  MemoryManifest ||= Rake::Pipeline::SpecHelpers::MemoryManifest
  ChainedFilter ||= Rake::Pipeline::Web::Filters::ChainedFilter

  input_file1 = MemoryFileWrapper.new("/path", "input.js.strip_asserts.erb", "UTF-8", <<-CONTENT)
assert("must be true", true);
Input = {};
<%= $chained_filter_title %> = {};
  CONTENT

  input_file2 = MemoryFileWrapper.new("/path", "input.js.erb.strip_asserts", "UTF-8", <<-CONTENT)
assert("must be true", true);
Input = {};
<%= $chained_filter_title %> = {};
  CONTENT

  input_file_accessing_context = MemoryFileWrapper.new("/path", "input.js.erb.strip_asserts", "UTF-8", <<-CONTENT)
assert("must be true", true);
Input = {};
<%= coming_from_context %> = {};
  CONTENT

  EXPECTED_OUTPUT = <<-EXPECTED

Input = {};
Chained = {};
  EXPECTED

  let(:erb_filter) do
    Class.new(Rake::Pipeline::Filter) do
      def initialize(context=nil)
        @context = context
      end

      def generate_output(inputs, output)
        inputs.each do |input|
          output.write ERB.new(input.read).result(@context)
        end
      end
    end
  end

  let(:strip_asserts_filter) do
    Class.new(Rake::Pipeline::Filter) do
      def generate_output(inputs, output)
        inputs.each do |input|
          output.write input.read.gsub(/^assert.*$/, '')
        end
      end
    end
  end

  before do
    $chained_filter_title = "Chained"
  end

  after do
    $chained_filter_title = nil
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.manifest = MemoryManifest.new
    filter.last_manifest = MemoryManifest.new
    filter.output_root = "/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  [ input_file1, input_file2 ].each do |file_wrapper|
    it "should run through the filters in order" do
      filter = setup_filter ChainedFilter.new(
        :types => {
          :erb => erb_filter,
          :strip_asserts => strip_asserts_filter
        }
      )

      filter.input_files = [ file_wrapper ]

      filter.output_files.should == [ MemoryFileWrapper.new("/output", "input.js", "UTF-8") ]

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)

      file = MemoryFileWrapper.files["/output/input.js"]
      file.body.should == EXPECTED_OUTPUT
      file.encoding.should == "UTF-8"
    end
  end

  it 'allows passing options to a filter' do
      coming_from_context = 'Chained'

      filter = setup_filter ChainedFilter.new(
        :types => {
          :erb => [ erb_filter, binding ],
          :strip_asserts => strip_asserts_filter
        }
      )

      filter.input_files = [ input_file_accessing_context ]

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)

      file = MemoryFileWrapper.files["/output/input.js"]
      file.body.should == EXPECTED_OUTPUT
  end

end
