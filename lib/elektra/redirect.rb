module Elektra
  class Base
    def redirect(*response)
      redirect_path = response.shift
      @response.redirect(redirect_path)
      update_response_with response
      throw :halt
    end

    def to(path)
      port = ":#{@request.port}" unless @request.port == 80
      "#{@request.host}#{port}#{path}"
    end
  end
end