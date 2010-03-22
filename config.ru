require "appengine-rack"
AppEngine::Rack.configure_app(
  :application => "ephemera-conv",
  :version => 2
)

require "mobipocket"
require "epub"

get "/" do
  "ephemera-conv. Yeeeeah, baby."
end

CACHE = AppEngine::Memcache.new
CACHE_TIME = 300 # sec

run Sinatra::Application
