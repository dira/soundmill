class User
  include DataMapper::Resource

  property :readmill_id, Integer, key: true
  property :readmill_fullname, String

  has n, :readings
end

class Book
  include DataMapper::Resource

  property :id,                  Serial
  property :soundcloud_id,       Integer
  property :readmill_id,         Integer

  has n, :readings
end

class Reading
  include DataMapper::Resource

  property :id,       Serial
  belongs_to :user
  belongs_to :book
  property :readmill_reading_id, Integer
  property :position, Integer
  property :permalink, String
end

DataMapper.finalize
