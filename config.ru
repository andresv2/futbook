require 'sinatra/base'
require 'sinatra/reloader'

require 'redis'
require 'facebook_oauth'

require_relative 'database_helper'
require_relative 'server'

run Futbook::Server
