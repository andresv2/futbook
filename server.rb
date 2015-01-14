module Futbook
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      register Sinatra::Reloader
      require 'pry'
    end

    get "/" do
      render :erb, :index
    end
  end
end
