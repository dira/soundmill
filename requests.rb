get '/' do
  user = nil
  if session[:readmill_user_id]
    user = User.first(readmill_id: session[:readmill_user_id])
  end

  haml :index, locals: {user: user}
end
