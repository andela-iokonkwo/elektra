require 'spec_helper'

module NameUtils
  def name
    "#{params['name'].capitalize }"
  end
end

class HelperServer < Elektra::Base

  helpers NameUtils

  helpers do
    def fullname
      "#{params['firstname'].capitalize } #{params['lastname'].capitalize}"
    end
  end

  get "/hello/:firstname/:lastname" do
    fullname
  end

  get "/hello/:name" do
    name
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(HelperServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#get" do
    it 'can see helpers defined in block' do
      uri = URI('https://localhost:3000/hello/ikem/okonkwo')

      response = Net::HTTP.get_response(uri)

      expect(response.body).to eq "Ikem Okonkwo"
    end

    it 'can see helpers defined in modules' do
      uri = URI('https://localhost:3000/hello/ikem')

      response = Net::HTTP.get_response(uri)

      expect(response.body).to eq "Ikem"
    end
  end
end
