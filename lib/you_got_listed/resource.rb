module YouGotListed
  class Resource

    attr_accessor :client

    def initialize(client)
      self.client = client
    end

    def process_get(path, params = {}, raise_error = false)
      Response.new(self.client.perform_request(:get, path, params), raise_error)
    end

    def process_post(path, params = {}, raise_error = false)
      Response.new(self.client.perform_request(:post, path, params), raise_error)
    end

  end
end
