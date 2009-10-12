module Tilt
  # ERB template implementation. See:
  # http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html
  #
  # It's suggested that your program require 'erb' at load
  # time when using this template engine.
  class ERBTemplate < Template
    def compile!
      require_template_library 'erb' unless defined?(::ERB)
      @engine = ::ERB.new(data, nil, nil, '@_out_buf')
    end

    def template_source
      @engine.src
    end

    def evaluate(scope, locals, &block)
      source, offset = local_assignment_code(locals)
      source = [source, template_source].join("\n")

      original_out_buf =
        scope.instance_variables.any? { |var| var.to_sym == :@_out_buf } &&
        scope.instance_variable_get(:@_out_buf)

      scope.instance_eval source, eval_file, line - offset

      output = scope.instance_variable_get(:@_out_buf)
      scope.instance_variable_set(:@_out_buf, original_out_buf)

      output
    end

  private

    # ERB generates a line to specify the character coding of the generated
    # source in 1.9. Account for this in the line offset.
    if RUBY_VERSION >= '1.9.0'
      def local_assignment_code(locals)
        source, offset = super
        [source, offset + 1]
      end
    end
  end
  %w[erb rhtml].each { |ext| register ext, ERBTemplate }
end