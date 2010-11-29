require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Listings do
  
  before do
    @ygl = new_ygl
    @listings = YouGotListed::Listings.new(@ygl)
  end
  
  context "search" do
    before do
      VCR.use_cassette('listings.search') do
        @response = @listings.search
      end
    end
    
    it { @response.should be_kind_of(YouGotListed::Listings::SearchResponse) }
    it { @response.success?.should be_true }
    
    context "search response" do
      it { @response.should be_kind_of(YouGotListed::Response) }
      it { @response.should respond_to(:properties, :paginator) }
      
      it "should return an array of properties" do
        @response.properties.should be_kind_of(Array)
        @response.properties.each do |property|
          property.should be_kind_of(YouGotListed::Listing)
        end
      end
      
      it "should return a will_paginate collection" do
        @response.paginator.should be_kind_of(WillPaginate::Collection)
        @response.paginator.collect{|p| p.id}.should == @response.properties.collect{|p| p.id}
      end
    end
  end
  
  context "find_by_id" do
    context "valid id" do
      before do
        VCR.use_cassette('listings.find_by_id') do
          @listing = @listings.find_by_id('CAM-000-382')
        end
      end
      
      it { @listing.should be_kind_of(YouGotListed::Listing) }
    end
    
    context "missing id" do
      before do
        VCR.use_cassette('listings.find_by_id_missing') do
          @listing = @listings.find_by_id('CAM-111-382')
        end
      end
      
      it { @listing.should be_nil }
    end
    
    context "invalid id" do
      it "should not raise an exception" do
        lambda {
          VCR.use_cassette('listings.find_by_id_invalid') do
            @listing = @listings.find_by_id('CAM')
          end
        }.should_not raise_exception
      end
      
      it "should be nil" do
        VCR.use_cassette('listings.find_by_id_invalid') do
          @listing = @listings.find_by_id('CAM')
        end
        @listing.should be_nil
      end
    end
  end
  
  context "find_all" do
    before do
      search_params = {:max_rent => "2000"}
      VCR.use_cassette('listings.find_all') do
        @properties = @listings.find_all(search_params)
      end
    end
    
    it { @properties.should be_kind_of(Array)}
  end
  
end
