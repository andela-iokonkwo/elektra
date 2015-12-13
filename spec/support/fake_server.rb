require "elektra"
class FakeServer < Elektra::Base
  get "/" do
    "Get request"
  end

  get "/new" do
    "I am a Boss"
  end

  post "/new" do
    [201, {}, req.body]
  end

  put "/new" do
    [200, {}, ["This is the new PUT endpoint with #{params} params "]]
  end
end