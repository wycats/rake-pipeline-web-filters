require "rake-pipeline-web-filters/helpers"

describe "Helpers" do

  let(:pipeline) { Rake::Pipeline.new }
  let(:dsl) { Rake::Pipeline::DSL.new(pipeline) }

  before do
    pipeline.add_input '.'
  end

  def filter
    pipeline.filters.last
  end

  describe "#concat" do
    it "creates a ConcatFilter" do
      dsl.concat "octopus"
      filter.should be_kind_of(Rake::Pipeline::ConcatFilter)
   end

    context "passed an Array first argument" do
      it "creates an OrderingConcatFilter" do
        dsl.concat ["octopus"]
        filter.should be_kind_of(Rake::Pipeline::Web::Filters::OrderingConcatFilter)
     end
    end
  end

  describe "#minispade" do
    it "creates a MinispadeFilter" do
      dsl.minispade
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::MinispadeFilter)
    end
  end

  describe "#sass" do
    it "creates a SassCompiler" do
      dsl.sass
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::SassCompiler)
    end
  end

  describe "#tilt" do
    it "creates a TiltFilter" do
      dsl.tilt
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::TiltFilter)
    end
  end

  describe "#markdown" do
    it "creates a MarkdownCompiler" do
      dsl.markdown
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::MarkdownCompiler)
    end
  end

  describe "#cache_buster" do
    it "creates a CacheBuster" do
      dsl.cache_buster
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::CacheBuster)
    end
  end

  describe "#coffee_script" do
    it "creates a CoffeeScriptCompiler" do
      dsl.coffee_script
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::CoffeeScriptCompiler)
    end
  end

  describe "#yui_javascript" do
    it "creates a YUIJavaScriptCompressor" do
      dsl.yui_javascript
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::YUIJavaScriptCompressor)
    end
  end

  describe "#yui_css" do
    it "creates a YUICssCompressor" do
      dsl.yui_css
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::YUICssCompressor)
    end
  end
end
