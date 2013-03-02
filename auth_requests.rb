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

  user_hash = fetch_and_parse("https://api.readmill.com/v2/me.json", token['access_token'])
  user = ensure_user_record(user_hash)

  session[:readmill_user_id] = user.readmill_id

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

def ensure_user_record(hash)
  user = User.first(readmill_id: hash["user"]["id"])
  if user == nil
    user = User.create({
      readmill_id:       hash["user"]["id"],
      readmill_fullname: hash["user"]["fullname"],
    })
  end
  user
end
