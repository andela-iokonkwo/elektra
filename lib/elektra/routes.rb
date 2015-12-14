
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
  end
end