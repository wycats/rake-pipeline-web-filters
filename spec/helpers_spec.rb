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

  describe "#minispade" do
    it "creates a MinispadeFilter" do
      dsl.minispade
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::MinispadeFilter)
    end
  end

  describe "#sass" do
    it "creates a SassCompiler" do
      dsl.sass
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::SassFilter)
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
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::MarkdownFilter)
    end
  end

  describe "#cache_buster" do
    it "creates a CacheBuster" do
      dsl.cache_buster
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::CacheBusterFilter)
    end
  end

  describe "#coffee_script" do
    it "creates a CoffeeScriptCompiler" do
      dsl.coffee_script
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::CoffeeScriptFilter)
    end
  end

  describe "#yui_javascript" do
    it "creates a YUIJavaScriptCompressor" do
      dsl.yui_javascript
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::YUIJavaScriptFilter)
    end
  end

  describe "#yui_css" do
    it "creates a YUICssCompressor" do
      dsl.yui_css
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::YUICssFilter)
    end
  end

  describe "#uglify" do
    it "creates an UglifyFilter" do
      dsl.uglify
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::UglifyFilter)
    end
  end

  describe "#less" do
    it "creates a LessFilter" do
      dsl.less
      filter.should be_kind_of(Rake::Pipeline::Web::Filters::LessFilter)
    end
  end
end
