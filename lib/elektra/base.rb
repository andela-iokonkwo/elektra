require "rack"

module Elektra
  class Base
    attr_reader :response

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

    %w(params body).each do |method_name|
      define_method(method_name) do
        @req.send(method_name)
      end
    end

    %w(status header).each do |method_name|
      define_method(method_name) do |*args|
        @response.send("#{method_name}=", *args)
      end
    end

    def call(env)
      @req = Rack::Request.new(env)
      @response = Rack::Response.new
      path = @req.path_info
      verb = @req.request_method.downcase.to_sym
      generate_response_for verb, path
      @response
    end

    def generate_response_for(verb, path)
      block_to_execute = execute_block_for(verb, path)
      execute_block_result = instance_eval(&block_to_execute)

      if execute_block_result
        if execute_block_result.is_a? String
          @response.write execute_block_result
        elsif execute_block_result.length == 3
          # require "pry"; binding.pry
          @response.status = execute_block_result[0]
          execute_block_result[1].each { |key, value| @response[key] = value }
          @response.body = execute_block_result[2]
        elsif execute_block_result.length == 2
          @response.status = execute_block_result[0]
          @response.body = execute_block_result[1]
        elsif execute_block_result.is_a? Fixnum
          @response.status = execute_block_result
        elsif execute_block_result.respond_to?(:each)
          @response.body = execute_block_result
        end

      else
        @response.write "This endpoint do not exist"
        @response.status = 404
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