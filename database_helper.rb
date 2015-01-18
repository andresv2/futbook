module Futbook
  module DataBaseHelper

    $redis = Redis.new

    def create_member(name, last_name, email, picture="")
      @id = $redis.incr("player_id")
      $redis.hmset(
        "player:#{@id}",
        "video",     video,
        "picture", picture,
        # "email",  email,
        "picture", picture
      )
      @id
    end

  end # DataBasHelper
end # Futbook
