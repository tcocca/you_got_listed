require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Client do

  before do
    @ygl = new_ygl
  end

  it "should set the api_key" do
    @ygl.class.default_params.should == {:key => YGL_API_KEY}
  end

  it "should set the base uri" do
    @ygl.class.base_uri.should == "https://www.yougotlistings.com/api"
  end

end
