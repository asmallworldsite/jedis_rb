# this is a generated file, to avoid over-writing it just delete this comment
begin
  require 'jar_dependencies'
rescue LoadError
  require 'redis/clients/jedis/2.9.0/jedis-2.9.0.jar'
  require 'org/apache/commons/commons-pool2/2.4.2/commons-pool2-2.4.2.jar'
end

if defined? Jars
  require_jar( 'redis.clients', 'jedis', '2.9.0' )
  require_jar( 'org.apache.commons', 'commons-pool2', '2.4.2' )
end
