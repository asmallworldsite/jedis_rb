require 'spec_helper'
require 'securerandom'

describe JedisRb::Pool do
  let(:instance) { described_class.new }
  let(:connection_pool) { instance.connection_pool }

  describe '#execute' do
    it 'executes single redis commands' do
      expect(instance.execute(:ping)).to eq('PONG')
    end
  end

  describe '#yield_connection' do
    it 'yields a redis connection' do
      instance.yield_connection do |c|
        expect(c).to be_an_instance_of(JedisRb::Wrapped::Connection)
      end
    end

    it 'allows the execution of multiple commands' do
      key = SecureRandom.hex(2)

      value = instance.yield_connection do |c|
        c.setex key, 2, 'hello!'
        c.get(key)
      end

      expect(value).to eq('hello!')
    end
  end

  describe 'connection pooling' do
    specify 'preconditions' do
      expect(connection_pool.num_active).to eq(0)
    end

    context 'when a connection is yielded' do
      it 'is leased by the pool' do
        instance.yield_connection do
          expect(connection_pool.num_active).to eq(1)
        end
      end
    end

    context 'after the block returns control' do
      it 'returns the connection to the pool' do
        instance.yield_connection { }

        expect(connection_pool.num_active).to eq(0)
      end
    end

    context 'when an exception occurs while the connection is leased' do
      it 'returns the connection to the pool' do
        begin
          instance.yield_connection { raise }
        rescue RuntimeError
        end

        expect(connection_pool.num_active).to eq(0)
      end
    end
  end
end
