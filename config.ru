require 'sinatra/base'
require 'sinatra/reloader'

require 'facebook_oauth'

require_relative 'server'

run Futbook::Server
