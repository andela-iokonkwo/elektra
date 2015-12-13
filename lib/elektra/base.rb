require "rack"
require_relative "helpers"
require_relative "filters"

module Elektra
  class Base
    attr_reader :response, :request

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
        @request.send(method_name)
      end
    end

    %w(status header).each do |method_name|
      define_method(method_name) do |*args|
        @response.send("#{method_name}=", *args)
      end
    end

    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      generate_response_for_request
      @response.finish
    end

    def path_and_verb
      [@request.path_info, @request.request_method.downcase.to_sym]
    end

    def generate_response_for_request
      execute_block_result = execute_block_and_before_filters

      if execute_block_result
        update_response_with execute_block_result
        execute_after_filters
      else
        @response.write "This endpoint do not exist"
        @response.status = 404
      end
    end

    def update_response_with(execute_block_result)
      if execute_block_result.is_a? String
          @response.write execute_block_result
      elsif execute_block_result.length == 3
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
    end

    def execute_block_and_before_filters
      block_to_execute = get_block_for_request

      # require "pry"; binding.pry
      self.class.filter_collection[:before].each do |before_filter|
        instance_eval(&before_filter)
      end
      instance_eval(&block_to_execute)
    end

    def execute_after_filters
      self.class.filter_collection[:after].each do |after_filter|
        instance_eval(&after_filter)
      end
    end


    def get_block_for_request
      path, verb = path_and_verb
      self.class.endpoints[verb].each do |route, block|
        pattern, placeholders = route
        if path =~ route[0]
          placeholders.each_with_index do |placeholder, index|
            @request.update_param(placeholder, eval("$#{index + 1}"))
          end
          return block
        end
      end
    end
  end
end