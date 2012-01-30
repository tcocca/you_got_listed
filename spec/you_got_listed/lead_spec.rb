require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Lead do

  before do
    @ygl = new_ygl
    @lead = YouGotListed::Lead.new(@ygl)
    @success_params = {:first_name => "You", :last_name => "GotListed", :email => "ygl@gmail.com"}
    @failed_params = {}
  end

  context "create" do
    context "a successful creation" do
      it "should not raise an exception" do
        lambda {
          VCR.use_cassette('lead.create.error') do
            @response = @lead.create(@success_params)
          end
        }.should_not raise_exception
      end
    end

    context "a failed creation" do
      it "should raise an exception" do
        lambda {
          VCR.use_cassette('lead.create.error') do
            @response = @lead.create(@failed_params)
          end
        }.should_not raise_exception
      end
    end
  end

  context "create!" do
    context "a successful creation" do
      it "should not raise an exception" do
        lambda {
          VCR.use_cassette('lead.create.error') do
            @response = @lead.create!(@success_params)
          end
        }.should_not raise_exception
      end
    end

    context "a failed creation" do
      it "should raise an exception" do
        lambda {
          VCR.use_cassette('lead.create.error') do
            @response = @lead.create!(@failed_params)
          end
        }.should raise_exception(YouGotListed::Error, "YouGotListed Error: Lead first name not specified. (code: 303)")
      end
    end
  end

end
