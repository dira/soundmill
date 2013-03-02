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

  begin
    response = RestClient.post("https://readmill.com/oauth/token.json", token_params)
  rescue => e
    p e
  end
  token = JSON.parse(response.to_s)

  user_hash = readmill_call('get', "/me.json", token['access_token'])
  user = ensure_user_record(user_hash)

  session[:readmill_user_id] = user.readmill_id
  session[:readmill_user_token] = token['access_token']


  redirect ''
end

get '/sign-out' do
  session[:readmill_user_id] = nil
  redirect ''
end

def ensure_user_record(hash)
  User.first(readmill_id: hash["user"]["id"]) ||
    user = User.create({
      readmill_id:       hash["user"]["id"],
      readmill_fullname: hash["user"]["fullname"],
    })
end
