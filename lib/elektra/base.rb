require "rack"

module Elektra
  class Base

    class << self

      def self.route_methods(*methods)
        Array(methods).each do |method_name|
          define_method(method_name) do |*args, &block|
            endpoints[method_name][args[0]] = block
          end
        end
      end

      route_methods :get, :patch, :put, :post, :delete, :head

      def endpoints
        @endpoints ||= Hash.new { |hash, key| hash[key] = {} }
      end
    end

    def params
      @req.params
    end

    def call(env)
      @req = Rack::Request.new(env)
      path = @req.path_info
      verb = @req.request_method.downcase.to_sym
      block_to_execute = self.class.endpoints[verb].fetch(path, nil)

      if block_to_execute
        response = instance_eval(&block_to_execute)
        if response.class == String
          [200, {"Content-Type" => "text/html"}, [response]]
        else
          response
        end
      else
        [404, {}, ["This endpoint do not exist"]]
      end
    end

  end
end