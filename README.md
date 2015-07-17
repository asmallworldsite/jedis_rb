# JedisRb

A JRuby wrapper around the Jedis client library for Redis.  Requires JRuby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jedis_rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jedis_rb

## Usage

```
RedisPool = JedisRb::Pool.new
=> #<JedisRb::Pool:0x19fe4644 @pool=#<Java::RedisClientsJedis::JedisPool:0x21d8bcbe>>
```

```
RedisPool.execute(:ping)
=> "PONG"
```

```
RedisPool.execute :get, 'foo'
=> nil
```

```
RedisPool.execute :set, 'foo', 'fish'
=> "OK"
```

```
RedisPool.execute :get, 'foo'
=> "fish"
```

```
RedisPool.execute :setex, 'foo', 600, 'fish'
=> "OK"
```

Or in parallel, in a block:

```
RedisPool.with_connection do |c|
  c.set ..., ...
  c.sadd ..., ...
  c.get ...
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/asmallworldsite/jedis_rb.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

