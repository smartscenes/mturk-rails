# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run MTurkRails::Application

# Uncomment to use reverse proxy to serve assets
require 'rack/reverse_proxy'

use Rack::ReverseProxy do
  #reverse_proxy /^.*\/ws\/\/?(.*)$/, 'http://host:port/ws/$1'
  #reverse_proxy /^(.*)/, 'host:port'
end
