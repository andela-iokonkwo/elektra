require 'spec_helper'

class FakeServer < Elektra::Base
  get "/" do
    "Get request"
  end

  get "/rack" do
    [201, {}, ["Get request to rack endpoint"]]
  end

  get "/with_params" do
    "Get request made with param name = #{params['name']}"
  end

  put "/new" do
    [200, {}, ["This is the new PUT endpoint with  #{params} params "]]
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

      response = Net::HTTP.get(uri)

      expect(response).to eq "Get request"
    end

    it 'can respond with a rack compatible response when a get request is issued' do
      uri = URI('https://localhost:3000/rack')

      response = Net::HTTP.get(uri)

      expect(response).to eq "Get request to rack endpoint"
    end

    it 'can retrieve params passed when a get request with params is issued' do
      uri = URI('https://localhost:3000/with_params?name=ikem')

      response = Net::HTTP.get(uri)

      expect(response).to eq "Get request made with param name = ikem"
    end

  end
end
