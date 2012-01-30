require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe YouGotListed::Complexes do

  before do
    @ygl = new_ygl
    @complexes = YouGotListed::Complexes.new(@ygl)
  end

  context "search" do
    before do
      VCR.use_cassette('complexes.search') do
        @response = @complexes.search
      end
    end

    it { @response.should be_kind_of(YouGotListed::Complexes::SearchResponse) }
    it { @response.success?.should be_true }

    context "search response" do
      it { @response.should be_kind_of(YouGotListed::Response) }
      it { @response.should respond_to(:property_complexes, :paginator) }

      it "should return an array of property_complexes" do
        @response.property_complexes.should be_kind_of(Array)
        @response.property_complexes.each do |property|
          property.should be_kind_of(YouGotListed::Complex)
        end
      end

      it "should return a will_paginate collection" do
        @response.paginator.should be_kind_of(WillPaginate::Collection)
        @response.paginator.collect{|p| p.id}.should == @response.property_complexes.collect{|p| p.id}
      end
    end
  end

  context "find_by_id" do
    context "valid id" do
      before do
        VCR.use_cassette('complexes.search') do
          @valid_complex_id = @complexes.search.property_complexes.first.id
        end
        VCR.use_cassette('complexes.find_by_id') do
          @complex = @complexes.find_by_id(@valid_complex_id)
        end
      end

      it { @complex.should be_kind_of(YouGotListed::Complex) }
    end

    context "missing id" do
      before do
        VCR.use_cassette('complexes.find_by_id_missing') do
          @complex = @complexes.find_by_id('CSM-111-382')
        end
      end

      it { @complex.should be_nil }
    end

    context "invalid id" do
      it "should not raise an exception" do
        lambda {
          VCR.use_cassette('complexes.find_by_id_invalid') do
            @complex = @complexes.find_by_id('CAM')
          end
        }.should_not raise_exception
      end

      it "should be nil" do
        VCR.use_cassette('complexes.find_by_id_invalid') do
          @complex = @complexes.find_by_id('CAM')
        end
        @complex.should be_nil
      end
    end
  end

end
