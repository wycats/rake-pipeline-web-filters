describe "TiltYieldingFilter" do
  TiltYieldingFilter  ||= Rake::Pipeline::Web::Filters::TiltYieldingFilter
  MemoryFileWrapper   ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  before do
    @input_path = "/path/to/input"
    @output_path = "/path/to/output"
    @encoding = "UTF-8"
    @default_output = "a.out"
  end

  before do
    @input_files = [
      ["first.erb","First <%= yield %> /First"],
      ["second.erb","Second <%= yield %> /Second"],
      ["third.erb","Third"],
    ].map{|a| MemoryFileWrapper.new @input_path, a.first, @encoding, a.last}
  end

  describe "when output is generated using default options" do
    before do
      @filter = TiltYieldingFilter.new
      @filter.file_wrapper_class = MemoryFileWrapper
      @filter.input_files = @input_files
      @filter.output_root = @output_path
      @filter.rake_application = Rake::Application.new
    end

    before do
      @expected_output = "First Second Third /Second /First"
    end

    it "should group the input files into one rake task" do
      tasks = @filter.generate_rake_tasks
      tasks.length.should == 1
      tasks.first.prerequisites.should =~ @input_files.map{|a| "#{a.root}/#{a.path}"}
    end

    it "should generate the output nesting each input file at the yield" do
      tasks = @filter.generate_rake_tasks
      tasks.each(&:invoke)
      MemoryFileWrapper.files["#{@output_path}/#{@default_output}"].body.should == @expected_output
    end
  end

  describe "when a yield order is provided for the generated output" do
    before do
      @yields_to = ["second","first","third"]
    end

    before do
      @filter = TiltYieldingFilter.new :yields_to => @yields_to
      @filter.file_wrapper_class = MemoryFileWrapper
      @filter.input_files = @input_files
      @filter.output_root = @output_path
      @filter.rake_application = Rake::Application.new
    end

    before do
      @expected_output = "Second First Third /First /Second"
    end

    it "should generate the output nesting each input file at the yield with respect to the ordering" do
      tasks = @filter.generate_rake_tasks
      tasks.each(&:invoke)
      MemoryFileWrapper.files["#{@output_path}/#{@default_output}"].body.should == @expected_output
    end
  end

  describe "when output is generated using a locals or a scope" do
    before do
      @input_files = [
        ["first.erb","<%= first %> <%= yield %> /<%= first %>"],
        ["second.erb","<%= second %> <%= yield %> /<%= second %>"],
        ["third.erb","<%= third %>"],
      ].map{|a| MemoryFileWrapper.new @input_path, a.first, @encoding, a.last}
    end

    before do
      @first = "abc"
      @second = "xyz"
      @third = "oh snap!"
      @expected_output = "#{@first} #{@second} #{@third} /#{@second} /#{@first}"
    end

    describe "when locals are used to define the variables" do
      before do
        @filter = TiltYieldingFilter.new :locals => {
          :first => @first,
          :second => @second,
          :third => @third
        }
        @filter.file_wrapper_class = MemoryFileWrapper
        @filter.input_files = @input_files
        @filter.output_root = @output_path
        @filter.rake_application = Rake::Application.new
      end

      it "should generate the output nesting each input file at the yield" do
        tasks = @filter.generate_rake_tasks
        tasks.each(&:invoke)
        MemoryFileWrapper.files["#{@output_path}/#{@default_output}"].body.should == @expected_output
      end
    end

    describe "when a scope is used to define the variables" do
      before do
        @scope = Class.new do
          def initialize first,second,third
            @first = first
            @second = second
            @third = third
          end
          def first; @first; end
          def second; @second; end
          def third; @third; end
        end.new(@first,@second,@third)
      end
      before do
        @filter = TiltYieldingFilter.new :scope => @scope
        @filter.file_wrapper_class = MemoryFileWrapper
        @filter.input_files = @input_files
        @filter.output_root = @output_path
        @filter.rake_application = Rake::Application.new
      end

      it "should generate the output nesting each input file at the yield" do
        tasks = @filter.generate_rake_tasks
        tasks.each(&:invoke)
        MemoryFileWrapper.files["#{@output_path}/#{@default_output}"].body.should == @expected_output
      end
    end
  end
end
