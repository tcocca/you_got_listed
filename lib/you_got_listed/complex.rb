module YouGotListed
  class Complex

    attr_accessor :client

    def initialize(listing, client)
      listing.each do |key, value|
        self.instance_variable_set("@#{key}", value)
        self.class.send(:attr_reader, key)
      end
      self.client = client
    end

    def properties
      @cached_properties ||= begin
        props = []
        if defined?(self.listings) && !self.listings.blank?
          if self.listings.listing.is_a?(Array)
            self.listings.listing.each do |listing|
              listing = listing.merge(find_address(listing.address_id))
              props << YouGotListed::Listing.new(listing, self.client)
            end
          else
            listing = self.listings.listing.merge(find_address(self.listings.listing.address_id))
            props << YouGotListed::Listing.new(listing, self.client)
          end
        end
        props
      end
    end

    def pictures
      self.photos.photo unless self.photos.blank? || self.photos.photo.blank?
    end

    def find_address(address_id)
      if addresses.address.is_a?(Array)
        if address_id.blank?
          addresses.address.first
        else
          addresses.address.find{|address| address.id == address_id}
        end
      else
        addresses.address
      end
    end

  end
end
