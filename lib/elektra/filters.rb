module Elektra
  class Base
    class << self
      %w{before after}.each do |filter|
        define_method(filter) do |&block|
          filter_collection[filter.to_sym] << block
        end
      end

      def filter_collection
        @filters ||= Hash.new { |hash, key| hash[key] = [] }
      end
    end
  end
end