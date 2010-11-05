module YouGotListed
  class Client
    
    include HTTParty
    format :json
    base_uri "test.yougotlistings.com"
    
    attr_accessor :api_key
    
    def initialize(api_key)
      self.api_key = api_key
    end
    
  end
end
