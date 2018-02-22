module YouGotListed
  class Listings < Resource

    def search(params = {})
      params[:page_count] ||= 20
      params[:page_index] ||= 1
      params[:sort_name] ||= "rent"
      params[:sort_dir] ||= "asc"
      params[:detail_level] ||= 2
      SearchResponse.new(self.client.perform_request(:get, '/rentals/search.php', params), self.client, params[:page_count])
    end

    def featured(params = {}, featured_tag = 'Featured Rentals')
      if params[:tags].blank?
        params[:tags] = featured_tag
      else
        params[:tags] += (params[:tags].ends_with?(',') ? featured_tag : ",#{featured_tag}")
      end
      search(params)
    end

    def find_by_id(listing_id)
      listing_id_key = listing_id.to_s.match(/7\d{7}/) ? :external_id : :listing_id
      params = {listing_id_key => listing_id, :detail_level => 2}
      response = SearchResponse.new(self.client.perform_request(:get, '/rentals/search.php', params), self.client, 20)
      (response.success? && response.properties.size > 0) ? response.properties.first : nil
    end

    def find_all(params = {})
      params[:page_count] ||= 20
      all_listings = []
      response = search(params)
      if response.success?
        all_listings << response.properties
        total_pages = (response.ygl_response.total.to_i/params[:page_count].to_f).ceil
        if total_pages > 1
          (2..total_pages).each do |page_num|
            resp = search(params.merge(:page_index => page_num))
            if resp.success?
              all_listings << resp.properties
            end
          end
        end
      end
      all_listings.flatten
    end

    def find_all_by_ids(listing_ids, include_off_market = true)
      listing_ids = listing_ids.split(',') if listing_ids.is_a?(String)
      all_listings = []
      search_params = {}
      search_params[:include_off_market] = 1 if include_off_market
      if listing_ids.any?{|list_id| list_id !=~ /[A-Z]{3}-[0-9]{3}-[0-9]{3}/}
        search_params[:include_mls] = 1
      end
      listing_ids.in_groups_of(20, false).each do |group|
        group.delete_if{|x| x.nil?}
        search_params[:listing_ids] = group.join(',')
        all_listings << find_all(search_params)
      end
      all_listings.compact.flatten
    end

    class SearchResponse < YouGotListed::Response

      attr_accessor :limit, :client

      def initialize(response, client, limit = 20, raise_error = false)
        super(response, raise_error)
        self.limit = limit
        self.client = client
      end

      def properties
        @cached_properties ||= begin
          props = []
          if self.success? && !self.ygl_response.listings.blank?
            if self.ygl_response.listings.listing.is_a?(Array)
              self.ygl_response.listings.listing.each do |listing|
                props << YouGotListed::Listing.new(listing, self.client)
              end
            else
              props << YouGotListed::Listing.new(self.ygl_response.listings.listing, self.client)
            end
          end
          props
        end
      end

      def mls_results?
        @has_mls_properties ||= properties.any?{|property| property.mls_listing?}
      end

      def paginator
        @paginator_cache ||= WillPaginate::Collection.create(
          (self.ygl_response.page_index ? self.ygl_response.page_index : 1),
          self.limit,
          (self.ygl_response.total ? self.ygl_response.total : properties.size)) do |pager|
          pager.replace properties
        end
      end
    end

  end
end
