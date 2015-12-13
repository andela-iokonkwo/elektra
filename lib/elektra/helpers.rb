module Elektra
  class Base
    class << self

      def helpers(*args)
        if block_given?
          command = Proc.new { yield }
          class_eval(&command)
          helpers_collection << command
        else
          args.each do |helper|
            command = "include #{ helper}"
            class_eval(command)
            helpers_collection << command
          end
        end
      end

      def helpers_collection
        @helpers ||= []
      end
    end
  end
end