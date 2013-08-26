module YouGotListed
  class Listing

    attr_accessor :client

    def initialize(listing, client)
      listing.each do |key, value|
        self.instance_variable_set("@#{key}", value)
        unless ["latitude", "longitude"].include?(key)
          self.class.send(:attr_reader, key)
        end
      end
      self.client = client
    end
    
    def similar_listings_criteria
      {
        :price_low => (self.price.to_i * 0.9).to_i,
        :price_high => (self.price.to_i * 1.1).to_i,
        :min_beds => ((self.beds.to_i - 1) <= 0 ? 0 : (self.beds.to_i - 1)),
        :max_beds => self.beds.to_i + 1,
        :min_baths => ((self.baths.to_i - 1) <= 0 ? 0 : (self.baths.to_i - 1)),
        :max_baths => self.baths.to_i + 1,
        :towns => self.city_neighborhood
      }
    end

    def similar_listings(limit = 6, search_options = {})
      criteria = similar_listings_criteria
      search_params = {
        :limit => limit + 1,
        :min_rent => criteria[:price_low],
        :max_rent => criteria[:price_high],
        :min_bed => criteria[:min_beds],
        :max_bed => criteria[:max_beds],
        :baths => [criteria[:min_baths], self.baths, criteria[:max_baths]].join(','),
        :city_neighborhood => self.city_neighborhood
      }.merge(search_options)
      @cached_similars ||= begin
        similar = []
        listings = YouGotListed::Listings.new(self.client)
        listings.search(search_params).properties.each do |prop|
          similar << prop unless prop.id == self.id
          break if similar.size == limit
        end
        similar
      end
    end

    def town_neighborhood
      str = self.city
      str += " - #{neighborhood}" unless self.neighborhood.blank?
      str
    end

    def city_neighborhood
      str = self.city
      str += ":#{neighborhood}" unless self.neighborhood.blank?
      str
    end

    def pictures
      (self.photos.photo.is_a?(Array) ? self.photos.photo : [self.photos.photo])  unless self.photos.blank? || self.photos.photo.blank?
    end

    def main_picture
      pictures.first if pictures
    end

    def mls_listing?
      source && source == "MLS"
    end

    def latitude
      @latitude.to_f unless @latitude.blank?
    end

    def longitude
      @longitude.to_f unless @longitude.blank?
    end

  end
end
