require 'spec_helper'
require 'elektra/base'


class RedirectServer < Elektra::Base
  get "/" do
    status 201
    "Get request"
  end

  get "/hello" do
    redirect to('/redirected_to')
  end

  get "/redirected_to" do
    "redirect to endpoint"
  end

end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(RedirectServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#redirect" do
    it 'can redirect to a given url' do
      uri = URI('https://localhost:3000/hello')

      response = Net::HTTP.get_response(uri)
      expect(response["location"]).to eq "localhost:3000/redirected_to"
      expect(response.code).to eq "302"
    end
  end
end
