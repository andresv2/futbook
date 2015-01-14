require 'sinatra/base'
require 'sinatra/reloader'

require_relative 'server'

run Futbook::Server
