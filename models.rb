class User
  include DataMapper::Resource

  property :readmill_id, Integer, key: true
  property :readmill_fullname, String
end

class Book
  include DataMapper::Resource

  property :id,                  Serial
  property :soundcloud_id,       Integer
  property :readmill_id,         Integer
end

class Reading
  include DataMapper::Resource

  property :id,       Serial
  belongs_to :user
  belongs_to :book
  property :position, Integer
end

DataMapper.finalize
