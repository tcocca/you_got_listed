module YouGotListed
  class Lead < Resource
    
    def create(lead_params = {}, raise_error = false)
      process_post("/leads/insert.php", lead_params, raise_error)
    end
    
    def create!(lead_params = {})
      create(lead_params, true)
    end
    
  end
end
