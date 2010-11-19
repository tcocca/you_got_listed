require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Accounts do
  
  before do
    @ygl = new_ygl
    @accounts = YouGotListed::Accounts.new(@ygl)
  end
  
  context "search" do
    before do
      VCR.use_cassette('accounts.search') do
        @response = @accounts.search
      end
    end
    
    it "should be a success" do
      @response.success?.should be_true
    end
    
    it "should set accounts on the response" do
      @response.ygl_response.accounts.should be_kind_of(Hashie::Rash)
    end
  end
  
end
