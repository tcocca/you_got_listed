module YouGotListed
  class Response

    attr_accessor :ygl_response

    def initialize(response, raise_error = true)
      begin
        if !response.respond_to?(:each_pair)
          self.ygl_response = nil
          raise Error.new('empty_response', 'Empty Response') if raise_error
        else
          rash = Hashie::Mash::Rash.new(response)
          self.ygl_response = rash.ygl_response
          if !success? && raise_error
            if self.ygl_response.respond_to?(:response_code)
              raise Error.new(self.ygl_response.response_code, self.ygl_response.error)
            else
              raise Error.new('empty_response', 'Empty Response')
            end
          end
        end
      rescue MultiXml::ParseError
        self.ygl_response = nil
        raise Error.new('parse_error', 'XML Parse Error') if raise_error
      end
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
