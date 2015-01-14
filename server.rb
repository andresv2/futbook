module Futbook
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      register Sinatra::Reloader
      require 'pry'
    end

    get "/" do
      client = FacebookOAuth::Client.new(
        :application_id     => ENV["FACEBOOK_OAUTH_ID"],
        :application_secret => ENV["FACEBOOK_OAUTH_SECRET"],
        :callback           => 'http://localhost:9292/facebook/callback'
      )

      @facebook_oauth_link = client.authorize_url
      render :erb, :index
    end

    get "/facebook/callback" do
      client = FacebookOAuth::Client.new(
        :application_id     => ENV["FACEBOOK_OAUTH_ID"],
        :application_secret => ENV["FACEBOOK_OAUTH_SECRET"],
        :callback           => 'http://localhost:9292/facebook/callback'
      )

      access_token = client.authorize(:code => params["code"])
      user_info    = client.me.info

      user_info["timezone"] = user_info["timezone"].to_s
      user_info["verified"] = user_info["verified"].to_s
      session[:access_token] = access_token.token
      session[:user]         = user_info

      redirect to("/players/" + session["user"]["id"])
    end

    get "/players/:id" do
      render :erb, :profile
    end


  end
end
