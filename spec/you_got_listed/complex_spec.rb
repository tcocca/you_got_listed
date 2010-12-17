require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Complex do
  
  before do
    @ygl = new_ygl
    @complex = YouGotListed::Complex.new(valid_complex_rash, @ygl)
  end
  
  it "should return photos for pictures" do
    @complex.pictures.should == @complex.photos.photo
  end
  
  it "should create methods from all hash keys" do
    @complex.should respond_to("id", "name", "addresses", "public_notes", "photos", "listings")
  end
  
  it "should return an array of properties" do
    @complex.properties.should be_kind_of(Array)
    @complex.properties.each do |property|
      property.should be_kind_of(YouGotListed::Listing)
    end
    @complex.properties.size.should == 2
  end
  
end
