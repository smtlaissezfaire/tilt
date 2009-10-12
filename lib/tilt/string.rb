module Tilt
  # The template source is evaluated as a Ruby string. The #{} interpolation
  # syntax can be used to generated dynamic output.
  class StringTemplate < Template
    def compile!
      @code = "%Q{#{data}}"
    end

    def template_source
      @code
    end
  end
  register :str, StringTemplate
end