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
  
  context "should raise errors" do
    before do
      @ygl = YouGotListed::Client.new('fake_key')
      @accounts = YouGotListed::Accounts.new(@ygl)
    end
    
    it "should raise an exception" do
      lambda {
        VCR.use_cassette('accounts.search.error') do
          @response = @accounts.search
        end
      }.should raise_exception(YouGotListed::Error, "YouGotListed Error: Invalid key. (code: 998)")
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
  
  context "passing raise_errors = false" do
    before do
      @ygl = new_ygl
      @mocked_response = httparty_get(@ygl.class.base_uri, '/accounts/search.php', 'error.xml', @ygl.class.default_params)
    end
    
    it "should not raise errors when raise_errors is false" do
      lambda {
        YouGotListed::Response.new(@mocked_response, false)
      }.should_not raise_exception
    end
    
    it "should not be a success" do
      @response = YouGotListed::Response.new(@mocked_response, false)
      @response.success?.should be_false
    end
  end
  
end
