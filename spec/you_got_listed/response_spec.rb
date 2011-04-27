require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Response do
  
  context "should not raise errors" do
    before do
      @ygl = new_ygl
      @accounts = YouGotListed::Accounts.new(@ygl)
    end
    
    it "should not raise an exception" do
      lambda {
        VCR.use_cassette('accounts.search') do
          @response = @accounts.search
        end
      }.should_not raise_exception
    end
  end
  
  context "should return a response" do
    before do
      @ygl = new_ygl
      @accounts = YouGotListed::Accounts.new(@ygl)
    end
    
    it "should not raise an exception" do
      lambda {
        VCR.use_cassette('accounts.search') do
          @response = @accounts.search
        end
      }.should_not raise_exception
    end
    
    it "should be a success" do
      VCR.use_cassette('accounts.search') do
        @response = @accounts.search
      end
      @response.success?.should be_true
      @response.ygl_response.should_not be_nil
      @response.ygl_response.should be_kind_of(Hashie::Rash)
    end
  end
  
  context "method missing" do
    before do
      @ygl = new_ygl
      @accounts = YouGotListed::Accounts.new(@ygl)
      VCR.use_cassette('accounts.search') do
        @response = @accounts.search
      end
    end
    
    it "should allow response.ygl_response methods to be called on response" do
      body = stub(:total_count => 25)
      @response.ygl_response = body
      @response.total_count.should == 25
    end
    
    it "should call super if ygl_response does not respond to the method" do
      lambda { @response.bad_method }.should raise_error(NoMethodError, /undefined method `bad_method'/)
    end
  end
  
  context "passing raise_errors = true" do
    before do
      @ygl = new_ygl
      @mocked_response = httparty_get(@ygl.class.base_uri, '/accounts/search.php', 'error.xml', @ygl.class.default_params)
    end
    
    it "should raise errors when raise_errors is true" do
      lambda {
        YouGotListed::Response.new(@mocked_response, true)
      }.should raise_exception(YouGotListed::Error, "YouGotListed Error: Invalid key. (code: 998)")
    end
  end
  
  context "client timeout error" do
    before do
      @ygl = new_ygl
      YouGotListed::Client.stub!(:get).and_raise(Timeout::Error)
      @accounts = YouGotListed::Accounts.new(@ygl)
    end
    
    it "should not raise errors" do
      lambda {
        @response = @accounts.search
      }.should_not raise_exception
    end
    
    it "should not be a success" do
      @response = @accounts.search
      @response.success?.should be_false
      @response.response_code.should == "996"
      @response.error.should == "Timeout"
    end
  end
  
  context "client exception" do
    before do
      @ygl = new_ygl
      YouGotListed::Client.stub!(:get).and_raise(Exception)
      @accounts = YouGotListed::Accounts.new(@ygl)
    end
    
    it "should not raise errors" do
      lambda {
        @response = @accounts.search
      }.should_not raise_exception
    end
    
    it "should not be a success" do
      @response = @accounts.search
      @response.success?.should be_false
      @response.response_code.should == "999"
      @response.error.should == "Unknown Error"
    end
  end
  
end
