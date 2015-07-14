module JedisRb
  class Pool
    def initialize(options={})
      config = options.fetch(:config) { Wrapped::PoolConfig.new }
      host = options.fetch(:host, Wrapped::Protocol::DEFAULT_HOST)
      port = options.fetch(:post, Wrapped::Protocol::DEFAULT_PORT)
      connection_timeout = options.fetch(:connection_timeout, Wrapped::Protocol::DEFAULT_TIMEOUT)
      password = options.fetch(:password, nil)
      database = options.fetch(:database, Wrapped::Protocol::DEFAULT_DATABASE)
      client_name = options.fetch(:client_name, nil)

      @pool = Wrapped::Pool.new(
        config,
        host,
        port,
        connection_timeout,
        password,
        database,
        client_name
      )
    end

    def yield_connection
      begin
        resource = @pool.resource
        yield resource
      ensure
        resource.close
      end
    end

    def execute(method, *args)
      yield_connection do |connection|
        connection.send(method, *args)
      end
    end
  end
end

