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

  it "should return similar listings criteria" do
    @listing.similar_listings_criteria.should ==
      {
        :towns=>"Boston:Fenway",
        :min_baths=>0,
        :min_beds=>0,
        :max_baths=>2,
        :max_beds=>1,
        :price_low=>720,
        :price_high=>880
      }
  end

  context "default similar listings" do
    before do
      VCR.use_cassette('listing.similar_listings') do
        @similar_props = @listing.similar_listings
      end
    end

    it "should return an array of listings" do
      @similar_props.should be_kind_of(Array)
      # @similar_props.should have_at_most(6).listings
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
      # @similar_props.should have_at_most(4).listings
      @similar_props.collect{|x| x.id}.should_not include(@listing.id)
    end
  end

  context "similar listings with custom params" do
    before do
      VCR.use_cassette('listing.similar_listings_custom') do
        @similar_props = @listing.similar_listings(4, :include_mls => "1")
      end
    end

    it "should return an array of listings" do
      @similar_props.should be_kind_of(Array)
      # @similar_props.should have_at_most(4).listings
      @similar_props.collect{|x| x.id}.should_not include(@listing.id)
    end
  end

  context "empty response" do
    before do
      min_baths = ((@listing.baths.to_i - 1) <= 0 ? 0 : (@listing.baths.to_i - 1))
      max_baths = @listing.baths.to_i + 1
      min_rent = (@listing.price.to_i * 0.9).to_i
      max_rent = (@listing.price.to_i * 1.1).to_i
      min_beds = ((@listing.beds.to_i - 1) <= 0 ? 0 : (@listing.beds.to_i - 1))
      max_beds = @listing.beds.to_i + 1
      httparty_get(@ygl.class.base_uri, '/rentals/search.php', 'empty.xml', @ygl.class.default_params.merge({
          :limit => 7.to_s,
          :min_rent => min_rent.to_s,
          :max_rent => max_rent.to_s,
          :min_bed => min_beds.to_s,
          :max_bed => max_beds.to_s,
          :baths => [min_baths, @listing.baths, max_baths].join(','),
          :city_neighborhood => @listing.city_neighborhood,
          :page_count => 20.to_s,
          :page_index => 1.to_s,
          :sort_name => "rent",
          :sort_dir => "asc",
          :detail_level => 2.to_s
        })
      )
      @similar_props = @listing.similar_listings
    end

    it "should return an empty array of listings" do
      @similar_props.should be_empty
    end
  end

  context "blank response" do
    before do
      min_baths = ((@listing.baths.to_i - 1) <= 0 ? 0 : (@listing.baths.to_i - 1))
      max_baths = @listing.baths.to_i + 1
      min_rent = (@listing.price.to_i * 0.9).to_i
      max_rent = (@listing.price.to_i * 1.1).to_i
      min_beds = ((@listing.beds.to_i - 1) <= 0 ? 0 : (@listing.beds.to_i - 1))
      max_beds = @listing.beds.to_i + 1
      httparty_get(@ygl.class.base_uri, '/rentals/search.php', 'blank.xml', @ygl.class.default_params.merge({
          :limit => 7.to_s,
          :min_rent => min_rent.to_s,
          :max_rent => max_rent.to_s,
          :min_bed => min_beds.to_s,
          :max_bed => max_beds.to_s,
          :baths => [min_baths, @listing.baths, max_baths].join(','),
          :city_neighborhood => @listing.city_neighborhood,
          :page_count => 20.to_s,
          :page_index => 1.to_s,
          :sort_name => "rent",
          :sort_dir => "asc",
          :detail_level => 2.to_s
        })
      )
      @similar_props = @listing.similar_listings
    end

    it "should return an empty array of listings" do
      @similar_props.should be_empty
    end
  end

  context "mls_listing" do
    before do
      @listing = YouGotListed::Listing.new(valid_listing_rash.merge(:source => 'MLS'), @ygl)
    end

    it "should be a mls_listing" do
      @listing.mls_listing?.should be true
    end
  end

  context "main_picture" do
    it "should return the first photo" do
      @listing.main_picture.should == @listing.pictures.first
      @listing.main_picture.should == "http://yougotlistings.com/photos/AC-000-103/500141.jpg"
    end

    it "should return nil if no pictures" do
      @listing.should_receive(:pictures).and_return(nil)
      @listing.main_picture.should be_nil
    end

    it "should return an array if the property has only one photo" do
      rash = valid_listing_rash
      rash[:photos].merge!(:photo => 'http://ygl-photos.s3.amazonaws.com/1236380.jpg')
      @listing = YouGotListed::Listing.new(rash, @ygl)
      @listing.pictures.is_a?(Array).should be true
      @listing.main_picture.should == 'http://ygl-photos.s3.amazonaws.com/1236380.jpg'
    end
  end

  context "latitude" do
    it "should return a float" do
      @listing.latitude.should be_kind_of(Float)
      @listing.latitude.should == 42.346182
    end

    it "should return nil if blank" do
      @listing = YouGotListed::Listing.new(valid_listing_rash.merge(:latitude => ''), @ygl)
      @listing.latitude.should be_nil
    end
  end

  context "longitude" do
    it "should return a float" do
      @listing.longitude.should be_kind_of(Float)
      @listing.longitude.should == -71.104427
    end

    it "should return nil if blank" do
      @listing = YouGotListed::Listing.new(valid_listing_rash.merge(:longitude => ''), @ygl)
      @listing.longitude.should be_nil
    end
  end

end
