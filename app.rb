require 'sinatra'
require 'rest_client'
require 'data_mapper'
require 'haml'

require './models'
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/development.db")

set :readmill_client_id, "45cb44f6d5c87fb45af92890e174d213"
set :readmill_client_secret, "ac98685f5ceb4319ab5b0cb9dcb3f5d0"
set :callback_url, "http://soundmill.dev/callback"

enable  :sessions

require './requests.rb'
require './auth_requests.rb'

get '/scripts/audiobooks.js' do
  coffee :audiobooks
end

def readmill_call(method, path, token, params={})
  url = "https://api.readmill.com/v2#{path}?client_id=#{settings.readmill_client_id}"
  url = "#{url}&access_token=#{token}" if token
  content = RestClient.send(method, url, params).to_str
  JSON.parse(content)
end
