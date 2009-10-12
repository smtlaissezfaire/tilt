module Tilt
  # Sass template implementation. See:
  # http://haml.hamptoncatlin.com/
  #
  # Sass templates do not support object scopes, locals, or yield.
  #
  # It's suggested that your program require 'sass' at load
  # time when using this template engine.
  class SassTemplate < Template
    def compile!
      require_template_library 'sass' unless defined?(::Sass::Engine)
      @engine = ::Sass::Engine.new(data, sass_options)
    end

    def evaluate(scope, locals, &block)
      @engine.render
    end

  private
    def sass_options
      options.merge(:filename => eval_file, :line => line)
    end
  end
  register :sass, SassTemplate
end