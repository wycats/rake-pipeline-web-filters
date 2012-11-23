require "rake-pipeline-I18n-filters/helpers"

describe "Helpers" do
  let(:pipeline) { Rake::Pipeline.new }
  let(:dsl) { Rake::Pipeline::DSL::PipelineDSL.new(pipeline) }

  before do
    pipeline.add_input '.'
  end

  def filter
    pipeline.filters.last
  end

  describe '#i18n_js' do
    it "creates an I18nJsFilter" do
      dsl.i18n_js
      filter.should be_kind_of(Rake::Pipeline::I18n::Filters::I18nJsFilter)
    end
  end
  describe '#ember_strings' do
    it "creates an EmberStringsFilter" do
      dsl.ember_strings
      filter.should be_kind_of(Rake::Pipeline::I18n::Filters::EmberStringsFilter)
    end
  end
end
