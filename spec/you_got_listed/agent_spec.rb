require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Agent do

  before do
    @ygl = new_ygl
    @agent = YouGotListed::Agent.new(@ygl)
  end

  context "find_all" do
    before do
      VCR.use_cassette('agent.find_all') do
        @response = @agent.find_all
      end
    end

    it "should be a success" do
      @response.success?.should be_true
    end

    it "should return an array of agents" do
      @response.agents.agent.should_not be_nil
      @response.agents.agent.should be_kind_of(Array)
    end
  end

  context "successful find" do
    before do
      VCR.use_cassette('agent.find_all') do
        @valid_agent_id = @agent.find_all.agents.agent.first.id
      end
      VCR.use_cassette('agent.find') do
        @response = @agent.find(@valid_agent_id)
      end
    end

    it "should be a success" do
      @response.success?.should be_true
    end

    it "should return an array of agents" do
      @response.agents.agent.should_not be_nil
      @response.agents.agent.should be_kind_of(Hashie::Rash)
    end
  end

  context "unsuccessful find" do
    it "should raise an exception" do
      lambda {
        VCR.use_cassette('agent.find.error') do
          @response = @agent.find('AG-001-0499957')
        end
      }.should raise_exception(YouGotListed::Error, "YouGotListed Error: Invalid user id. (code: 301)")
    end
  end

  context "successful find_by_id" do
    before do
      VCR.use_cassette('agent.find_all') do
        @valid_agent_id = @agent.find_all.agents.agent.first.id
      end
      VCR.use_cassette('agent.find') do
        @response = @agent.find_by_id(@valid_agent_id)
      end
    end

    it "should be a success" do
      @response.success?.should be_true
    end

    it "should return an array of agents" do
      @response.agents.agent.should_not be_nil
      @response.agents.agent.should be_kind_of(Hashie::Rash)
    end
  end

  context "unsuccessful find_by_id" do
    it "should raise an exception" do
      lambda {
        VCR.use_cassette('agent.find.error') do
          @response = @agent.find_by_id('AG-001-0499957')
        end
      }.should_not raise_exception
    end

    it "should not be a success" do
      VCR.use_cassette('agent.find.error') do
        @response = @agent.find_by_id('AG-001-0499957')
      end
      @response.success?.should be_false
    end
  end

end
