require 'spec_helper'
require 'elektra/base'

class HaltServer < Elektra::Base

  before do
    halt "I am the new response"
  end

  get "/hello" do
    "#{@name}"
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(HaltServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#halt" do
    it 'can stop execution at any point' do
      uri = URI('https://localhost:3000/hello')

      response = Net::HTTP.get_response(uri)

      expect(response.body).to eq "I am the new response"
    end
  end
end
