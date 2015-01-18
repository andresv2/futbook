module Futbook
 class Server < Sinatra::Base

    enable :logging, :sessions
    include Futbook

    configure :development do
      register Sinatra::Reloader
      $redis = Redis.new
      require 'pry'
    end

    get "/" do
      redirect_uri = "http://localhost:9292/facebook/callback"
      client = FacebookOAuth::Client.new(
        :application_id     => ENV["FACEBOOK_OAUTH_ID"],
        :application_secret => ENV["FACEBOOK_OAUTH_SECRET"],
        :callback           => redirect_uri
        )
      # @facebook_oauth_link = "https://www.facebook.com/dialog/oauth?client_id=#{ENV["FACEBOOK_OAUTH_ID"]}&redirect_uri=#{redirect_uri}"
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
        # $redis.hset "player:#{id}", "link",   user_info["link"]
        $redis.hset "player:#{id}", "location", user_info["location"]
      end
      # set the user's id and access token in to the session
      session[:access_token] = access_token.token
      session[:user_id]      = user_info["id"]
      redirect to("/players/#{id}")
    end # get '/facebook/callback'

    get '/agents' do
      agent_ids = $redis.lrange('agent_ids', 0, -1)
      @agents = agent_ids.map { |id| $redis.hgetall("agent:#{id}")}
      render(:erb, :agents)
    end

    get('/agents/new') do
      render(:erb, :new)
    end


    get '/agents/:id' do
      id= params[:id]
      @agent = $redis.hgetall "agent#{:id}"

       render :erb, :profile
    end


    get '/players' do
      player_ids = $redis.lrange('player_ids', 0, -1)
      @players = player_ids.map { |id| $redis.hgetall("player:#{id}")}
      render(:erb, :players)
    end


    get('/players/new') do
      render(:erb, :new)
    end


    get '/players/:id' do
      id = params[:id]
      # get the player profile from the db, with the given id
      @player = $redis.hgetall "player:#{id}"
       # binding.pry
       render :erb, :profile
    end


    post('/players') do
      # binding.pry
      # save the information to the user
      id = $redis.incr("player_id")
      $redis.hmset(
          "player:#{id}",
          "review",  params[:review],
          "picture", params[:picture],
          "video",   params[:video]
      )
      $redis.lpush("player_ids", id)
      $redis.lpush("player:#{session[:user_id]}:players", id)
      redirect to("/players/#{id}")
    end

    post('/agents') do
      id = $redis.incr("agent_id")
      $redis.hmset(
       "agent:#{id}",
       "member", params[:member],
       "first_name", params[:first_name],
       "last_name", params[:last_name]

      )
      $redis.lpush("agent_ids", id)
      redirect to ('/agents')
    end


   get('/logout') do
      session[:user_id] = nil
      session[:access_token] = nil # dual assignment!
      redirect to('/')
    end


  end # Server
end # Futbook


