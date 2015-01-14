module Futbook
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      register Sinatra::Reloader
      require 'pry'
    end

    get "/" do
      session[:client] = FacebookOAuth::Client.new(
        :application_id     => ENV["FACEBOOK_OAUTH_ID"],
        :application_secret => ENV["FACEBOOK_OAUTH_SECRET"],
        :callback           => 'http://localhost:9292/facebook/callback'
      )
      @facebook_oauth_link = session[:client].authorize_url
      render :erb, :index
    end

    get "/facebook/callback" do
      session[:client].authorize(:code => params["code"])
      user_info = session[:client].me.info

      binding.pry

      redirect to("/test")
    end

    get "/test" do
      render :erb, :index
    end


  end
end
