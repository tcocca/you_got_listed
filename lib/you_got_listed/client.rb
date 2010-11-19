module YouGotListed
  class Client
    
    include HTTParty
    format :xml
    base_uri "https://yougotlistings.com/api"
    
    attr_accessor :api_key
    
    def initialize(api_key)
      self.class.default_params :key => api_key
    end
    
  end
end
