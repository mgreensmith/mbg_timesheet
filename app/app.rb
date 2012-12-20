require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
      [username, password] == ['admin', 'admin']
end

get '/' do
      haml :index
end

