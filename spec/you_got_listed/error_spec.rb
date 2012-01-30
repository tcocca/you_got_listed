require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Error do

  it "should set a message" do
    @error = YouGotListed::Error.new(300, 'Account retrieving failed.')
    @error.message.should == "YouGotListed Error: Account retrieving failed. (code: 300)"
  end

end
