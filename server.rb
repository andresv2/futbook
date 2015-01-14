module Futbook
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      register Sinatra::Reloader
      require 'pry'
    end

    get "/" do
      "Hello World"
    end
  end
end
