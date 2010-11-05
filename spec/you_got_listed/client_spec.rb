require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Client do
  
  before do
    @ygl = new_ygl
  end
  
  it "should set the api_key" do
    @ygl.api_key.should == YGL_API_KEY
  end
  
  it "should set the base uri" do
    @ygl.class.base_uri.should == "http://test.yougotlistings.com"
  end
  
end
