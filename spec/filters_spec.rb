require 'spec_helper'
require 'elektra/base'

class BeforeServer < Elektra::Base

  before do
    @name = "andela"
  end

  get "/hello" do
    "#{@name}"
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(BeforeServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#before" do
    it 'execute any block called by :before method before executing route blocks' do
      uri = URI('https://localhost:3000/hello')

      response = Net::HTTP.get_response(uri)

      expect(response.body).to eq "andela"
    end
  end
end

class AfterServer < Elektra::Base

  after do
    status 401
  end

  get "/hello" do
    "hello Ikem"
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(AfterServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#after" do
    it 'execute any block called by :after method immediately after executing route blocks' do
      uri = URI('https://localhost:3000/hello')

      response = Net::HTTP.get_response(uri)

      expect(response.code).to eq "401"
    end
  end
end
