require 'slim'
module Elektra
  class Base
    def render(template, layout: true)
      filename = File.join("views","#{template}.slim")
      scope = Object.new
      instance_variable_to_view.each { |key, value| scope.instance_variable_set(key, value) }
      compiled_template = Slim::Template.new(filename).render(scope)
      compiled_template = Slim::Template.new("views/layout.slim").render { compiled_template } if layout
      compiled_template
    end

    def instance_variable_to_view
      var_to_be_passed = instance_variables - [:@request, :@response]
      var_to_be_passed .map { |name| [name, instance_variable_get(name)] }
    end
  end
end