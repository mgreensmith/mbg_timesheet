require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'

require 'date'
use Rack::Auth::Basic, "Restricted Area" do |username, password|
      [username, password] == ['admin', 'admin']
end

helpers do
  # Returns a hash for the week like
  # { :monday_date => (Date.to_s),
  #   :month => populated only if it's the first week of the month
  #   :days => [ day numbers] }
  def get_week(week_index) #this week is 0, last week -1
    day = Date.today + Integer(week_index) * 7
    prev_mon = day - day.cwday + 1
    next_sun = prev_mon + 6
    { 
      :monday_date => prev_mon.to_s, 
      :month => next_sun.day > 7 ? '&nbsp' : "<strong>#{next_sun.strftime("%b")}</strong>", 
      :days => prev_mon.upto(next_sun).collect {|e| e.day}
    }
  end

 # Construct a link to +url_fragment+, which should be given relative to
  # the base of this Sinatra app.  The mode should be either
  # <code>:path_only</code>, which will generate an absolute path within
  # the current domain (the default), or <code>:full_url</code>, which will
  # include the site name and port number.  The latter is typically necessary
  # for links in RSS feeds.  Example usage:
  #
  #   link_to "/foo" # Returns "http://example.com/myapp/foo"
  #
  #--
  # Thanks to cypher23 on #mephisto and the folks on #rack for pointing me
  # in the right direction.
  def link_to url_fragment, mode=:path_only
    case mode
    when :path_only
      base = request.script_name
    when :full_url
      if (request.scheme == 'http' && request.port == 80 ||
          request.scheme == 'https' && request.port == 443)
        port = ""
      else
        port = ":#{request.port}"
      end
      base = "#{request.scheme}://#{request.host}#{port}#{request.script_name}"
    else
      raise "Unknown script_url mode #{mode}"
    end
    "#{base}#{url_fragment}"
  end
end

get '/' do
      haml :index
end

get "/week/:index" do
  h = get_week(params[:index])
  "Monday date: #{h[:monday_date]}<br>Month: #{h[:month]}<br>Days: #{h[:days].inspect}"
end

get "/cal/:first/:last" do
  @rows = []
  (Integer(params[:first])..Integer(params[:last])).each do |i|
    w = get_week(i)
    @rows << [w[:month], w[:days]].flatten
  end
  haml :cal
end

