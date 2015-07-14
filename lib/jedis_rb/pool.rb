module JedisRb
  # Pool wraps redis.clients.jedis.JedisPool, providing a thread-safe pool
  # of redis.clients.jedis.Jedis connections.
  #
  # It provides two methods for performing Redis operations:
  #   * #yield_connection - yields a Jedis instance to a block
  #   * #execute - executes a single Redis operation
  #
  class Pool
    attr_reader :connection_pool

    # Construct a new JedisRb Pool.
    #
    # Possible options are:
    #   * config - (redis.clients.jedis.JedisPoolConfig/Wrapped::PoolConfig) the pool configuration
    #   * host - (String) Redis host
    #   * port - (Integer) Redis port
    #   * connection_timeout - (Integer) the connection timeout in milliseconds
    #   * password - (String) Redis password
    #   * database - (Integer) Redis database
    #   * client_name (String) the client name
    #   * convert_objects (Boolean) Ruby object casting
    #
    # By passing in convert_objects: true, Pool can convert return values to
    # their Ruby type equivalent. Currently, the following are supported:
    #   * java.util.Set => Set
    #   * java.util.Map => Hash
    #   * java.util.List => Array
    #
    # Depending on your use case, this conversion may be costly, so it is not
    # the default. Please evaluate your application's requirements carefully
    # before opting in.
    def initialize(options={})
      config = options.fetch(:config) { Wrapped::PoolConfig.new }
      host = options.fetch(:host, Wrapped::Protocol::DEFAULT_HOST)
      port = options.fetch(:post, Wrapped::Protocol::DEFAULT_PORT)
      connection_timeout = options.fetch(:connection_timeout, Wrapped::Protocol::DEFAULT_TIMEOUT)
      password = options.fetch(:password, nil)
      database = options.fetch(:database, Wrapped::Protocol::DEFAULT_DATABASE)
      client_name = options.fetch(:client_name, nil)

      @convert_objects = options.fetch(:convert_objects, false)

      @connection_pool = Wrapped::Pool.new(
        config,
        host,
        port,
        connection_timeout,
        password,
        database,
        client_name
      )
    end

    # Lease a connection from the pool and yield it to the given block.
    #
    # Leased connections will be automatically returned to the pool upon successful
    # or unsuccessful execution of the block.
    #
    # Connections are of type redis.clients.jedis.Jedis.
    # See the documentation[https://github.com/xetorthio/jedis/wiki] for more details.
    def yield_connection
      response = begin
        resource = @connection_pool.resource
        yield resource
      ensure
        resource.close if resource
      end

      if @convert_objects
        convert(response)
      else
        response
      end
    end

    # Execute a single action on the a Redis connection from the pool.
    # Takes a method name and a splat of arguments to pass to the method.
    #
    # #execute uses #yield_connection to handle pool interaction.
    def execute(method, *args)
      yield_connection do |connection|
        connection.send(method, *args)
      end
    end

    private

    # Convert Java return values to their ruby equivalents.
    def convert(value)
      case value
      when java.util.List then value.to_a
      when java.util.Set then value.to_set
      when java.util.Map then value.to_hash
      else value
      end
    end
  end
end

