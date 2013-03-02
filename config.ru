require 'rubygems'
require './app'
require './models'
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/development.db")

run Sinatra::Application
