$redis =Redis.new
$redis.flushbd

$redis.hmset("players")
