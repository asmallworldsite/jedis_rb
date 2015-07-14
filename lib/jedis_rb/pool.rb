module JedisRb
  class Pool
    attr_reader :connection_pool

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

    def execute(method, *args)
      yield_connection do |connection|
        connection.send(method, *args)
      end
    end

    private

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

