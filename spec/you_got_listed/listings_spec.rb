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
  
  context "mls_search" do
    before do
      VCR.use_cassette('listings.mls_search') do
        @response = @listings.search(:include_mls => "1")
        @response.properties.first.stub!(:source).and_return('MLS')
      end
    end
    
    context "search response" do
      it { @response.mls_results?.should be_true }
    end
  end
  
  context "featured" do
    before do 
      VCR.use_cassette('listings.featured') do
        @response = @listings.featured
      end
    end
    
    it "should only return featured properties" do
      @response.properties.find_all{|p| p.tags && (p.tags.tag.include?('Featured Rentals') || p.tags.tag.include?('Featured'))}.size.should == @response.properties.size
    end
  end
  
  context "find_by_id" do
    context "valid id" do
      before do
        VCR.use_cassette('listings.search') do
          @valid_listing_id = @listings.search.properties.first.id
        end
        VCR.use_cassette('listings.find_by_id') do
          @listing = @listings.find_by_id(@valid_listing_id)
        end
      end
      
      it { @listing.should be_kind_of(YouGotListed::Listing) }
    end
    
    context "missing id" do
      before do
        VCR.use_cassette('listings.find_by_id_missing') do
          @listing = @listings.find_by_id('CAM-111-3823475')
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
      VCR.use_cassette('listings.search') do
        @find_ids = @listings.search.properties.collect{|p| p.id}
      end
      VCR.use_cassette("listings.search_with_off_market") do
        @response = @listings.search(:include_off_market => "1")
        @total_pages = @response.paginator.total_pages
      end
      (1..@total_pages).each do |page_num|
        if property_id = find_off_market_property(@listings, page_num)
          @off_market_id = property_id
          break
        end
      end
      @find_ids_with_off_market = @find_ids.clone
      @find_ids_with_off_market << @off_market_id if @off_market_id
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
    end
    
    context "should not return off market properties if directed not to" do
      before do
        VCR.use_cassette('listings.find_all_by_ids.no_off_market') do
          @properties = @listings.find_all_by_ids(@find_ids_with_off_market, false)
        end
      end
      
      it { @properties.size.should_not == @find_ids_with_off_market.size }
      it { @properties.collect{|p| p.id}.should_not include(@off_market_id) }
    end
    
    context "should find all properties including the mls properties" do
      before do
        VCR.use_cassette("listings.search_with_mls") do
          @response = @listings.search(:include_mls => "1")
          @total_pages = @response.paginator.total_pages
        end
        (1..@total_pages).each do |page_num|
          if property_id = find_mls_property(@listings, page_num)
            @mls_id = property_id
            break
          end
        end
        @find_ids_with_mls = @find_ids.clone
        @find_ids_with_mls << @mls_id if @mls_id
        VCR.use_cassette('listings.find_all_by_ids.include_mls') do
          @properties = @listings.find_all_by_ids(@find_ids_with_mls)
        end
      end
      
      it { @properties.size.should == @find_ids_with_mls.size }
      
      it "should only return properties for requested ids" do
        @properties.each do |p|
          @find_ids_with_mls.should include(p.id)
        end
      end
    end
  end
  
  def find_off_market_property(listings, page_id = 1)
    VCR.use_cassette("listings.search_with_off_market.#{page_id}") do
      response = listings.search(:include_off_market => "1", :page_index => page_id)
      if property = response.properties.find{|p| p.status == "OFFMARKET"}
        return property.id
      else
        return nil
      end
    end
  end
  
  def find_mls_property(listings, page_id = 1)
    VCR.use_cassette("listings.search_with_mls.#{page_id}") do
      response = listings.search(:include_mls => "1", :page_index => page_id)
      if property = response.properties.find{|p| p.source == "MLS"}
        return property.id
      else
        return nil
      end
    end
  end
  
end
