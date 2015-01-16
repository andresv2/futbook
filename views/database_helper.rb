require 'redis'
module Futbook
module DataBaseHelper
  REDIS = Redis.new
    def create_member(name, last_name, email)
      id = REDIS.incr("entry_id")
      REDIS.hmset(
        "entry:#{id}",
        "name",     name,
        "last_name", last_name
        "email",  email
      )

    end


end
end
