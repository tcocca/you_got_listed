module YouGotListed
  class Accounts
    
    attr_accessor :client
    
    def initialize(client)
      self.client = client
    end
    
    def search(optional_params = {})
      Response.new(self.client.class.get("/accounts/search.php", optional_params))
    end
    
  end
end
