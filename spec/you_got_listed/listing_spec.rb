require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Listing do
  
  before do
    @ygl = new_ygl
    @listing = YouGotListed::Listing.new(valid_listing_rash, @ygl)
  end
  
  it "should create methods from all hash keys" do
    @listing.should respond_to(
      "unit_level", "pet", "include_hot_water", "square_footage", "external_id", "zip", "student_policy", 
      "building_id", "parking", "split", "city", "neighborhood", "fee", "heat_source", "street_name", 
      "price", "building_type", "include_heat", "beds", "id", "agency_id", "status", "source", 
      "longitude", "available_date", "include_electricity", "latitude", "street_number", "unit", 
      "include_gas", "state", "baths", "photos"
    )
  end
  
  it "should return ygl id for id" do
    @listing.id.should == "BOS-182-933"
  end
  
  it "should return the city - neighborhood for town_neighborhood" do
    @listing.town_neighborhood.should == 'Boston - Fenway'
  end
  
  it "should return the city_neighborhood search param for city_neighborhood" do
    @listing.city_neighborhood.should == 'Boston:Fenway'
  end
  
  it "should return photos for pictures" do
    @listing.pictures.should == @listing.photos.photo
  end
  
  context "default similar listings" do
    before do
      VCR.use_cassette('listing.similar_listings') do
        @similar_props = @listing.similar_listings
      end
    end
    
    it "should return an array of listings" do
      @similar_props.should be_kind_of(Array)
      @similar_props.should have_at_most(6).listings
      @similar_props.collect{|x| x.id}.should_not include(@listing.id)
    end
  end
  
  context "similar listings with custom limit" do
    before do
      VCR.use_cassette('listing.similar_listings') do
        @similar_props = @listing.similar_listings(4)
      end
    end
    
    it "should return an array of listings" do
      @similar_props.should be_kind_of(Array)
      @similar_props.should have_at_most(4).listings
      @similar_props.collect{|x| x.id}.should_not include(@listing.id)
    end
  end
  
  context "mls_listing" do
    before do
      @listing = YouGotListed::Listing.new(valid_listing_rash.merge(:source => 'MLS'), @ygl)
    end
    
    it "should be a mls_listing" do
      @listing.mls_listing?.should be_true
    end
  end
  
end
