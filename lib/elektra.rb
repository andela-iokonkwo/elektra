require "elektra/base"
require "elektra/version"

module Elektra

  module Delegator

    methods_to_define = Base.methods - Object.methods

    def self.delegate(methods, to:)
      puts methods
      methods.each do |method_name|
        define_method(method_name) do |*args, &block|
          to.send(method_name, *args, &block)
        end
      end
    end

    delegate methods_to_define, to: Base
    Application = Base.new
  end
end

include Elektra::Delegator
