require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Resource do

  before do
    @ygl = new_ygl
    @resource = YouGotListed::Resource.new(@ygl)
  end

  context "initialize" do
    it "should instantiate with a client" do
      @resource.client.should_not be_nil
      @resource.client.should be_kind_of(YouGotListed::Client)
    end
  end

end
