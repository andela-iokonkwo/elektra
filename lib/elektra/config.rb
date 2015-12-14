module Elektra
  class Base
    @@configuration = { public_folder: 'public',
                        views_folder: 'views',
                        layout: 'layout'  }
    class << self
      def set(key, value)
        @@configuration[key] = value
      end
    end
  end
end