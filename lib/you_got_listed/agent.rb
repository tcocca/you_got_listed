module YouGotListed
  class Agent < Resource
    
    def find_all
      process_get("/agents/search.php")
    end
    
    def find_by_id(agent_id)
      get_agent(agent_id, false)
    end
    
    def find(agent_id)
      get_agent(agent_id)
    end
    
    private
    
    def get_agent(agent_id, raise_error = true)
      params = {:id => agent_id}
      process_get("/agents/search.php", params, raise_error)
    end
    
  end
end
