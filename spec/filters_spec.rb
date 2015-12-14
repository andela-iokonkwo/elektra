require 'spec_helper'
require 'elektra/base'

class FilterServer < Elektra::Base

  before do
    @name = "andela"
  end

  get "/hello" do
    "#{@name}"
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(FilterServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#get" do
    it 'can see helpers defined in block' do
      uri = URI('https://localhost:3000/hello')

      response = Net::HTTP.get_response(uri)

      expect(response.body).to eq "andela"
    end
  end
end
