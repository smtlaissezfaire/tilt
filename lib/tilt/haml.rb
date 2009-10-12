module Tilt
  # Haml template implementation. See:
  # http://haml.hamptoncatlin.com/
  #
  # It's suggested that your program require 'haml' at load
  # time when using this template engine.
  class HamlTemplate < Template
    def compile!
      require_template_library 'haml' unless defined?(::Haml::Engine)
      @engine = ::Haml::Engine.new(data, haml_options)
    end

    def evaluate(scope, locals, &block)
      @engine.render(scope, locals, &block)
    end

  private
    def haml_options
      options.merge(:filename => eval_file, :line => line)
    end
  end
  register :haml, HamlTemplate
end