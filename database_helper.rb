require 'redis'
module Futbook
module DataBaseHelper
  $redis = Redis.new
    def create_member(name, last_name, email)
      @id = $redis.incr("entry_id")
      $redis.hmset(
        "entry:#{id}",
        "name",     name,
        "last_name", last_name,
        "email",  email
      )

    end


end
end
