module Tilt
  # Liquid template implementation. See:
  # http://liquid.rubyforge.org/
  #
  # LiquidTemplate does not support scopes or yield blocks.
  #
  # It's suggested that your program require 'liquid' at load
  # time when using this template engine.
  class LiquidTemplate < Template
    def compile!
      require_template_library 'liquid' unless defined?(::Liquid::Template)
      @engine = ::Liquid::Template.parse(data)
    end

    def evaluate(scope, locals, &block)
      locals = locals.inject({}) { |hash,(k,v)| hash[k.to_s] = v ; hash }
      @engine.render(locals)
    end
  end
  register :liquid, LiquidTemplate
end