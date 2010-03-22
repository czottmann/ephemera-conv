require "appengine-rack"
AppEngine::Rack.configure_app(
  :application => "ephemera-conv",
  :version => 2
)

require "mobi"
require "epub"

run Sinatra::Application
