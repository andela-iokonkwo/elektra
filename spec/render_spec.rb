require 'spec_helper'
require 'elektra/base'


class RenderServer < Elektra::Base
  set :views_folder, File.dirname(__FILE__) + '/views'
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

  describe "#render" do
    it 'can render a view without a layout' do
      uri = URI('https://localhost:3000/about')

      response = Net::HTTP.get_response(uri)
      expect(response.body).to include "ikem.okonkwo@andela.com"
    end

    it 'can render a view with a layout' do
      uri = URI('https://localhost:3000/')

      response = Net::HTTP.get_response(uri)
      expect(response.body).to include "ikem.okonkwo@andela.com"
    end

    it 'can return a content-type of text/html if a view is rendered' do
      uri = URI('https://localhost:3000/')

      response = Net::HTTP.get_response(uri)
      expect(response["Content-Type"]).to eq "text/html"
    end
  end
end
