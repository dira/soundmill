require 'sinatra'
require 'rest_client'
require 'data_mapper'
require 'haml'
require 'coffee_script'
require 'json'

set :readmill_client_id,     ENV['READMILL_CLIENT_ID']
set :readmill_client_secret, ENV['READMILL_CLIENT_SECRET']
set :db_url,                 ENV['HEROKU_POSTGRESQL_CHARCOAL_URL'] || "sqlite3://#{Dir.pwd}/db/development.db"
set :environment,            ENV['RACK_ENV'] || 'development'
set :host,                   settings.environment == 'production' ? 'soundmill.herokuapp.com' : 'soundmill.dev'
set :callback_url,           "http://#{settings.host}/callback"

enable :sessions

require './models'
DataMapper.setup(:default, settings.db_url)


require './requests.rb'
require './auth_requests.rb'

get '/scripts/audiobooks.js' do
  coffee :audiobooks
end

def readmill_call(method, path, token, params={})
  url = "https://api.readmill.com/v2#{path}?client_id=#{settings.readmill_client_id}"
  url = "#{url}&access_token=#{token}" if token
  p method, url, params
  begin
    content = RestClient.send(method, url, params).to_str
    p content
    JSON.parse(content)
  rescue => e
    p 'error', e
  end
end
