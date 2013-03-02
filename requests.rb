get '/' do
  haml :index, locals: {user: current_user()}
end

post '/progress' do
  book = Book.first(soundcloud_id: params[:soundcloud_id])
  user = current_user()

  reading = ensure_reading(user, book)
  reading.update(position: params[:position])

  ping_reading(reading, params[:duration], params[:progress])
end

def current_user
  user = nil
  if session[:readmill_user_id]
    user = User.first(readmill_id: session[:readmill_user_id])
  end
  user
end

def ensure_reading(user, book)
  hash = {
    user_id: user.id,
    book_id: book.id,
  }
  reading = Reading.first(hash)
  return reading if reading != nil

  response = RestClient.post("https://api.readmill.com/v2/books/#{book.readmill_id}/readings", {
    state: 'reading'
  })
  reading_response = JSON.parse(response)

  hash[:readmill_reading_id] = reading_response["reading"]["id"]
  Reading.create(hash)
end


def ping_reading(reading, duration, progress)
  response = RestClient.post("https://api.readmill.com/v2/readings/#{reading.readmill_id}/ping", {
    ping: {
      identifier: 1,
      duration: duration,
      progress: progress,
    }
  })
end
