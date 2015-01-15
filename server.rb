module Futbook
  class Server < Sinatra::Base

    enable :logging, :sessions

    configure :development do
      register Sinatra::Reloader
      $redis = Redis.new

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
      # create a FB OAuth object
      client = FacebookOAuth::Client.new(
        :application_id     => ENV["FACEBOOK_OAUTH_ID"],
        :application_secret => ENV["FACEBOOK_OAUTH_SECRET"],
        :callback           => 'http://localhost:9292/facebook/callback'
      )

      # use the code FB sent us to get an access token for the user
      access_token = client.authorize(:code => params["code"])
      # get the user's basic fb info
      user_info    = client.me.info
      id           = user_info["id"]

      # see if the user exists in the database
      user_in_db = $redis.hget("player:#{id}", "id")
      if user_in_db == nil # if there is no user in the db
        # create the user in the database
        $redis.hset "player:#{id}", "id",     id
        $redis.hset "player:#{id}", "email",  user_info["email"]
        $redis.hset "player:#{id}", "name",   user_info["name"]
        $redis.hset "player:#{id}", "gender", user_info["gender"]
        $redis.hset "player:#{id}", "link",   user_info["link"]
        $redis.hset "player:#{id}", "locale", user_info["locale"]
      end

      # set the user's id and access token in to the session
      session[:access_token] = access_token.token
      session[:user_id]      = user_info["id"]

      redirect to("/players/#{id}")
    end

    get "/players/:id" do
      # get the player profile from the db, with the given id
      @player = $redis.hgetall "player:#{params["id"]}"

      render :erb, :profile
    end


  end
end
