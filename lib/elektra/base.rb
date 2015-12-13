require "rack"

module Elektra
  class Base

    class << self

      def self.route_methods(*methods)
        Array(methods).each do |method_name|
          define_method(method_name) do |*args, &block|
            pattern = args[0]
            endpoints[method_name] << [get_path(pattern), block]
          end
        end
      end

      route_methods :get, :patch, :put, :post, :delete, :head

      def endpoints
        @endpoints ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def get_path(pattern)
        placeholders = []
        pattern.gsub!(/(:\w+)/) do |match|
          placeholders << $1[1..-1]
          "([^/?#]+)"
        end
        [%r{^#{pattern}$}, placeholders]
      end
    end

    def params
      @req.params
    end

    def body
      @req.body
    end

    def call(env)
      @req = Rack::Request.new(env)
      path = @req.path_info
      verb = @req.request_method.downcase.to_sym
      block_to_execute = execute_block_for(verb, path)

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

    def execute_block_for(verb, path)
      self.class.endpoints[verb].each do |route, block|
        pattern, placeholders = route
        if path =~ route[0]
          placeholders.each_with_index do |placeholder, index|
            @req.update_param(placeholder, eval("$#{index + 1}"))
          end
          return block
        end
      end
    end
  end
end