module YouGotListed
  class Client
    
    include HTTParty
    format :xml
    base_uri "https://www.yougotlistings.com/api"
    
    attr_accessor :api_key
    
    def initialize(api_key)
      self.class.default_params :key => api_key
    end
    
    def perform_request(http_method, path, params = {})
      begin
        self.class.send(http_method, path, :query => params)
      rescue Timeout::Error
        {"YGLResponse" => {"responseCode" => "996", "Error" => "Timeout"}}
      rescue Exception
        {"YGLResponse" => {"responseCode" => "999", "Error" => "Unknown Error"}}
      end
    end
    
  end
end
