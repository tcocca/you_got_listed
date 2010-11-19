module YouGotListed
  class Accounts < Resource
    
    def search(optional_params = {})
      process_get("/accounts/search.php", optional_params)
    end
    
  end
end
