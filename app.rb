require 'sinatra'
require 'rest_client'

set :readmill_client_id, "45cb44f6d5c87fb45af92890e174d213"
set :readmill_client_secret, "ac98685f5ceb4319ab5b0cb9dcb3f5d0"
set :callback_url, "http://soundmill.dev/callback"

enable  :sessions

get '/' do
  haml :index
end

get '/auth' do
  redirect "https://readmill.com/oauth/authorize?response_type=code&client_id=#{settings.readmill_client_id}&redirect_uri=#{settings.callback_url}&scope=non-expiring"
end

get '/callback' do

  token_params = {
    grant_type:    'authorization_code',
    client_id:     settings.readmill_client_id,
    client_secret: settings.readmill_client_secret,
    redirect_uri:  settings.callback_url,
    code:          params[:code],
    scope:         'non-expiring'
  }

  response = RestClient.post("https://readmill.com/oauth/token.json", token_params)
  token = JSON.parse(response.to_s)

  user = fetch_and_parse("https://api.readmill.com/v2/me.json", token['access_token'])
  session[:readmill_user_id] = user["user"]["id"]

  redirect ''
end

get '/sign-out' do
  session[:readmill_user_id] = nil
  redirect ''
end

def fetch_and_parse(uri, token)
  url = "#{uri}?client_id=#{settings.readmill_client_id}"
  url = "#{url}&access_token=#{token}" if token
  content = RestClient.get(url, :accept => :json).to_str
  JSON.parse(content) rescue nil
end
