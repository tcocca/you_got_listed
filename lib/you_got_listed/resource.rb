module YouGotListed
  class Resource
    
    attr_accessor :client
    
    def initialize(client)
      self.client = client
    end
    
    def process_get(path, params = {}, raise_error = true)
      Response.new(self.client.class.get(path, :query => params), raise_error)
    end
    
    def process_post(path, params = {}, raise_error = true)
      Response.new(self.client.class.post(path, :query => params), raise_error)
    end
    
  end
end
