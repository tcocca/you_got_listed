YGL_API_KEY = YAML.load_file(File.join(File.dirname(__FILE__), '/../you_got_listed_api_key.yml'))["api_key"]

def new_ygl
  YouGotListed::Client.new(YGL_API_KEY)
end

def mock_get(base_uri, method, response_fixture, params = {})
  url = base_uri + method
  unless params.blank?
    stub_http_request(:get, url).with(:query => params).to_return(:body => mocked_response(response_fixture))
  else
    stub_http_request(:get, url).to_return(:body => mocked_response(response_fixture))
  end
end

def mocked_response(response_fixture)
  File.read(File.join(File.dirname(__FILE__), '/../fixtures/responses', "#{response_fixture}"))
end

def httparty_get(base_uri, method, response_fixture, params = {})
  mock_get(base_uri, method, response_fixture, params)
  url = base_uri + method
  VCR.use_cassette(method.gsub('/', '_')) do
    HTTParty.get url, :format => :xml
  end
end
