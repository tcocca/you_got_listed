module YouGotListed
  class Response
    
    attr_accessor :ygl_response
    
    def initialize(response, raise_error = true)
      rash = Hashie::Rash.new(response)
      self.ygl_response = rash.ygl_response
      raise Error.new(self.ygl_response.response_code, self.ygl_response.error) if !success? && raise_error
    end
    
    def success?
      self.ygl_response && self.ygl_response.respond_to?(:response_code) && self.ygl_response.response_code.to_i < 300
    end
    
    def method_missing(method_name, *args)
      if self.ygl_response.respond_to?(method_name)
        self.ygl_response.send(method_name)
      else
        super
      end
    end
    
  end
end
