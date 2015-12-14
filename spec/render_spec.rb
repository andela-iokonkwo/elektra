require 'spec_helper'
require 'elektra/base'


class RenderServer < Elektra::Base
  get "/about" do
    @user = {name: "ikem okonkwo", email: "ikem.okonkwo@andela.com"}
    @users = []
    @year = 2015
    @author = "Andela"
    render :about, layout: false
  end

  get "/" do
    @user = {name: "ikem okonkwo", email: "ikem.okonkwo@andela.com"}
    @users = []
    @year = 2015
    @author = "Andela"
    render :index
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost:3000/).to_rack(RenderServer.new)
  end
end

RSpec.describe Elektra::Base do

  describe "#get" do
    it 'can redirect to a given url' do
      uri = URI('https://localhost:3000/about')

      response = Net::HTTP.get_response(uri)
      expect(response.body).to include "ikem.okonkwo@andela.com"
    end

    it 'can redirect to a given url' do
      uri = URI('https://localhost:3000/')

      response = Net::HTTP.get_response(uri)
      expect(response.body).to include "ikem.okonkwo@andela.com"
    end
  end
end
