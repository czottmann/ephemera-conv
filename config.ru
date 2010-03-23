require "appengine-rack"
require "appengine-apis/memcache"
require "appengine-apis/logger"
require "mobipocket"
require "epub"

AppEngine::Rack.configure_app(
  :application => "ephemera-conv",
  :version => 1
)


CACHE = AppEngine::Memcache.new
CACHE_TIME = 300 # sec
LOGGER = AppEngine::Logger.new


get "/" do
  "ephemera-conv. Yeeeeah, baby."
end


run Sinatra::Application
