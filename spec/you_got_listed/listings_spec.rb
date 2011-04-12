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
  
  context "featured" do
    before do 
      VCR.use_cassette('listings.featured') do
        @response = @listings.featured
      end
    end
    
    it "should only return featured properties" do
      @response.properties.find_all{|p| p.tags && p.tags.tag.include?('Featured Rentals')}.size.should == @response.properties.size
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
    
    it "should only return properties" do
      @properties.each do |p|
        p.should be_kind_of(YouGotListed::Listing)
      end
    end
  end
  
  context "find_all_by_ids" do
    before do
      @find_ids = [
        'BOS-168-785', 'BOS-110-861', 'BOS-182-933', 'BOS-001-817', 'BOS-042-323', 'BOS-042-324', 'BOS-042-536', 
        'BOS-114-154', 'BOS-114-155', 'BOS-056-128', 'BOS-081-968', 'BOS-083-238', 'BOS-083-239', 'BOS-083-240', 
        'BOS-083-250', 'BOS-083-438', 'BOS-084-078', 'BOS-084-149', 'BOS-153-342', 'BOS-153-343'
      ]
    end
    
    context "passing an array of ids" do
      before do
        VCR.use_cassette('listings.find_all_by_ids.array') do
          @properties = @listings.find_all_by_ids(@find_ids)
        end
      end
      
      it { @properties.should be_kind_of(Array) }
      
      it "should only return properties for requested ids" do
        @properties.each do |p|
          @find_ids.should include(p.id)
        end
      end
    end
    
    context "passing an string of ids" do
      before do
        VCR.use_cassette('listings.find_all_by_ids.string') do
          @properties = @listings.find_all_by_ids(@find_ids.join(','))
        end
      end
      
      it { @properties.should be_kind_of(Array) }
      
      it "should only return properties for requested ids" do
        @properties.each do |p|
          @find_ids.should include(p.id)
        end
      end
    end
  end
  
end
