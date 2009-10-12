module Tilt
  # Discount Markdown implementation.
  class RDiscountTemplate < Template
    def compile!
      require_template_library 'rdiscount' unless defined?(::RDiscount)
      @engine = RDiscount.new(data)
    end

    def evaluate(scope, locals, &block)
      @engine.to_html
    end
  end
  register :markdown, RDiscountTemplate
end