module JedisRb
  module Wrapped
    Connection = Java::RedisClientsJedis::Jedis
    Pool = Java::RedisClientsJedis::JedisPool
    PoolConfig = Java::RedisClientsJedis::JedisPoolConfig
    Protocol = Java::RedisClientsJedis::Protocol
  end
end
