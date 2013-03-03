get '/' do
  haml :index, locals: {user: current_user()}
end

post '/progress' do
  book = Book.first(soundcloud_id: params[:soundcloud_id])
  user = current_user()

  reading = ensure_reading(user, book)
  reading.update(position: params[:position])

  ping_reading(reading, params[:duration], params[:progress], params[:ping_identifier])
end

post '/highlight' do
  book = Book.get(params[:book_id])
  reading = ensure_reading(current_user, book)

  readmill_call('post', "/readings/#{reading.readmill_reading_id}/highlights", current_token, {
    highlight: {
      content: params[:comment],
      locators: {
        position: params[:position],
        mid: params[:comment],
      }
    }
  })
  'ok'
end

def current_user
  user = nil
  if session[:readmill_user_id]
    user = User.first(readmill_id: session[:readmill_user_id])
  end
  user
end

def current_token
  session[:readmill_user_token]
end

def ensure_reading(user, book)
  hash = {
    user_readmill_id: user.readmill_id,
    book_id: book.id,
  }
  reading = Reading.first(hash)
  return reading if reading != nil

  reading_response = readmill_call('post', "/books/#{book.readmill_id}/readings", current_token, {
    reading: {
      state: 'reading'
    }
  })

  hash[:readmill_reading_id] = reading_response["reading"]["id"]
  Reading.create(hash)
end


def ping_reading(reading, duration, progress, identifier)
  response = readmill_call('post', "/readings/#{reading.readmill_reading_id}/ping", current_token, {
    ping: {
      identifier: identifier,
      duration: duration,
      progress: progress,
    }
  })
end
