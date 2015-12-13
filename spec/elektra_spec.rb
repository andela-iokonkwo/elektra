require 'spec_helper'

class FakeServer < Elektra::Base
  get "/" do
    status 201
  end

  get "/hello/:name" do
    "Hello #{params['name']}"
  end

  get "/with_params" do
    "Get request made with param name = #{params['name']}"
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(FakeServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#get" do
    it 'can respond with a string when a get request is issued' do
      uri = URI('https://localhost:3000/')

      response = Net::HTTP.get_response(uri)

      expect(response.body).to eq "Get request"
      expect(response.code).to eq "201"
    end

    it 'can retrieve query params passed when a get request with params is issued' do
      uri = URI('https://localhost:3000/with_params?name=ikem')

      response = Net::HTTP.get(uri)

      expect(response).to eq "Get request made with param name = ikem"
    end

    it 'can retrieve params passed when a get request with params is issued' do
      uri = URI('https://localhost:3000/hello/ikem')

      response = Net::HTTP.get(uri)

      expect(response).to eq "Hello ikem"
    end

  end
end
