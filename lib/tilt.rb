module Tilt
  @template_mappings = {}

  # Register a template implementation by file extension.
  def self.register(ext, template_class)
    ext = ext.to_s.sub(/^\./, '')
    @template_mappings[ext.downcase] = template_class
  end

  # Create a new template for the given file using the file's extension
  # to determine the the template mapping.
  def self.new(file, line=nil, options={}, &block)
    if template_class = self[File.basename(file)]
      template_class.new(file, line, options, &block)
    else
      fail "No template engine registered for #{File.basename(file)}"
    end
  end

  # Lookup a template class given for the given filename or file
  # extension. Return nil when no implementation is found.
  def self.[](filename)
    ext = filename.to_s.downcase
    until ext.empty?
      return @template_mappings[ext]  if @template_mappings.key?(ext)
      ext = ext.sub(/^[^.]*\.?/, '')
    end
    nil
  end

  # Base class for template implementations. Subclasses must implement
  # the #compile! method and one of the #evaluate or #template_source
  # methods.
  class Template
    # Template source; loaded from a file or given directly.
    attr_reader :data

    # The name of the file where the template data was loaded from.
    attr_reader :file

    # The line number in #file where template data was loaded from.
    attr_reader :line

    # A Hash of template engine specific options. This is passed directly
    # to the underlying engine and is not used by the generic template
    # interface.
    attr_reader :options

    # Create a new template with the file, line, and options specified. By
    # default, template data is read from the file specified. When a block
    # is given, it should read template data and return as a String. When
    # file is nil, a block is required.
    def initialize(file=nil, line=1, options={}, &block)
      raise ArgumentError, "file or block required" if file.nil? && block.nil?
      @file = file
      @line = line || 1
      @options = options || {}
      @reader = block || lambda { |t| File.read(file) }
    end

    # Render the template in the given scope with the locals specified. If a
    # block is given, it is typically available within the template via
    # +yield+.
    def render(scope=Object.new, locals={}, &block)
      if @data.nil?
        @data = @reader.call(self)
        compile!
      end
      evaluate scope, locals || {}, &block
    end

    # The filename used in backtraces to describe the template.
    def eval_file
      @file || '(__TEMPLATE__)'
    end

  protected
    # Do whatever preparation is necessary to "compile" the template.
    # Called immediately after template #data is loaded. Instance variables
    # set in this method are available when #evaluate is called.
    #
    # Subclasses must provide an implementation of this method.
    def compile!
      raise NotImplementedError
    end

    # Process the template and return the result. Subclasses should override
    # this method unless they implement the #template_source.
    def evaluate(scope, locals, &block)
      source, offset = local_assignment_code(locals)
      source = [source, template_source].join("\n")
      scope.instance_eval source, eval_file, line - offset
    end

    # Return a string containing the (Ruby) source code for the template. The
    # default Template#evaluate implementation requires this method be
    # defined.
    def template_source
      raise NotImplementedError
    end

  private
    def local_assignment_code(locals)
      return ['', 1] if locals.empty?
      source = locals.collect { |k,v| "#{k} = locals[:#{k}]" }
      [source.join("\n"), source.length]
    end

    def require_template_library(name)
      warn "WARN: loading '#{name}' library in a non thread-safe way; " +
           "explicit require '#{name}' suggested."
      require name
    end
  end

  # Extremely simple template cache implementation.
  class Cache
    def initialize
      @cache = {}
    end

    def fetch(*key)
      key = key.map { |part| part.to_s }.join(":")
      @cache[key] ||= yield
    end

    def clear
      @cache = {}
    end
  end

  # Template Implementations ================================================
  $LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
  
  autoload :StringTemplate,    "tilt/string"
  autoload :ERBTemplate,       "tilt/erb"
  autoload :HamlTemplate,      "tilt/haml"
  autoload :SassTemplate,      "tilt/sass"
  autoload :BuilderTemplate,   "tilt/builder"
  autoload :LiquidTemplate,    "tilt/liquid"
  autoload :RDiscountTemplate, "tilt/rdiscount"
end
