module Tilt
  # Builder template implementation. See:
  # http://builder.rubyforge.org/
  #
  # It's suggested that your program require 'builder' at load
  # time when using this template engine.
  class BuilderTemplate < Template
    def compile!
      require_template_library 'builder' unless defined?(::Builder)
    end

    def evaluate(scope, locals, &block)
      xml = ::Builder::XmlMarkup.new(:indent => 2)
      if data.respond_to?(:to_str)
        locals[:xml] = xml
        super(scope, locals, &block)
      elsif data.kind_of?(Proc)
        data.call(xml)
      end
      xml.target!
    end

    def template_source
      data.to_str
    end
  end
  register :builder, BuilderTemplate
end