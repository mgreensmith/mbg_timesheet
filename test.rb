require 'rubygems'
require 'bundler/setup'
require 'sinatra'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
      [username, password] == ['admin', 'admin']
end

get '/' do
      "You're welcome"
end

get '/foo' do
      "You're also welcome"
end
