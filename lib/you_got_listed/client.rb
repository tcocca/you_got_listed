module YouGotListed
  class Client

    include HTTParty
    format :xml
    base_uri "https://www.yougotlistings.com/api"

    attr_accessor :api_key, :http_timeout

    def initialize(api_key, http_timeout = nil)
      self.http_timeout = http_timeout
      self.class.default_params :key => api_key
    end

    def perform_request(http_method, path, params = {})
      begin
        http_params = {}
        unless params.blank?
          http_params[:query] = params
        end
        unless self.http_timeout.nil?
          http_params[:timeout] = self.http_timeout
        end
        self.class.send(http_method, path, http_params)
      rescue Timeout::Error
        {"YGLResponse" => {"responseCode" => "996", "Error" => "Timeout"}}
      rescue Exception
        {"YGLResponse" => {"responseCode" => "999", "Error" => "Unknown Error"}}
      end
    end

  end
end
