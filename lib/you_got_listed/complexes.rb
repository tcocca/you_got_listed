module YouGotListed
  class Complexes < Resource

    def search(params = {})
      params[:page_count] ||= 20
      params[:page_index] ||= 1
      params[:sort_name] ||= "Name"
      params[:sort_dir] ||= "asc"
      params[:detail_level] ||= 2
      SearchResponse.new(self.client.perform_request(:get, '/complexes/search.php', params), self.client, params[:page_count])
    end

    def find_by_id(complex_id)
      response = SearchResponse.new(self.client.perform_request(:get, '/complexes/search.php', {:complex_id => complex_id}), self.client, 20)
      (response.success? && response.property_complexes.size > 0) ? response.property_complexes.first : nil
    end

    class SearchResponse < YouGotListed::Response

      attr_accessor :limit, :paginator_cache, :client

      def initialize(response, client, limit = 20, raise_error = false)
        super(response, raise_error)
        self.limit = limit
        self.client = client
      end

      def property_complexes
        @cached_property_complexes ||= begin
          props = []
          if self.success? && !self.ygl_response.complexes.blank?
            if self.ygl_response.complexes.complex.is_a?(Array)
              self.ygl_response.complexes.complex.each do |complex|
                props << YouGotListed::Complex.new(complex, self.client)
              end
            else
              props << YouGotListed::Complex.new(self.ygl_response.complexes.complex, self.client)
            end
          end
          props
        end
      end

      def paginator
        paginator_cache if paginator_cache
        self.paginator_cache = WillPaginate::Collection.create(
          (self.ygl_response.page_index ? self.ygl_response.page_index : 1), 
          self.limit, 
          (self.ygl_response.total ? self.ygl_response.total : properties.size)) do |pager|
          pager.replace property_complexes
        end
      end
    end

  end
end
