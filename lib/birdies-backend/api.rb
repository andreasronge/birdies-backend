require 'net/http'

module BirdiesBackend

  module API

    module ClassMethods

      def server_url=(url)
        @server_url = URI.parse(url)
      end

      def server_url
        @server_url || URI.parse('http://localhost:7474')
      end


      def update_tweets(tweets)
        server_call('BirdiesBackend', 'update_tweets', tweets)
        JSON.parse(result)['return']
      end

      def server_eval(s)
        res = Net::HTTP.start(server_url.host, server_url.port) do |http|
          http.post('/script/jruby/eval', s)
        end
        [res.code, res.body]
      end

      def server_call(clazz, method, value)
        res = Net::HTTP.start(server_url.host, server_url.port) do |http|
          http.post("/script/jruby/cal?classandmethod=#{clazz}.#{method}", value)
        end
        [res.code, res.body]
      end

    end

    extend ClassMethods

  end
end
