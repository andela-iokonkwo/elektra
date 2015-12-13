require 'spec_helper'

class FakeServer < Elektra::Base
  get "/" do
    "Get request"
  end

  get "/rack" do
    [201, {}, ["Get request to rack endpoint"]]
  end

  put "/new" do
    [200, {}, ["This is the new PUT endpoint with #{params} params "]]
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(FakeServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#get" do
    it 'returns a rack compatible reponse when a get request is issued' do
      uri = URI('https://localhost:3000/')

      response = Net::HTTP.get(uri)

      expect(response).to eq "Get request"
    end

    it 'returns reponse when a get request is issued' do
      uri = URI('https://localhost:3000/rack')

      response = Net::HTTP.get(uri)

      expect(response).to eq "Get request to rack endpoint"
    end
  end
end
