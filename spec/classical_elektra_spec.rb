require 'spec_helper'
require 'elektra'

get "/" do
  status 201
  "Get request"
end

get "/hello/:name" do
  [301, {}, ["Hello #{params['name']}"]]
end

get "/with_params" do
  "Get request made with param name = #{params['name']}"
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(Application)
  end
end

RSpec.describe "Classical" do

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


