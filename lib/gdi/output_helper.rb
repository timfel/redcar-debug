require File.expand_path("../../../vendor/haml/lib/haml", __FILE__)

module GDI::OutputHelper
  Swt::Widgets::Display.default.async_exec do
    SYSTEM_BGCOLOR = Swt::Widgets::Display.default.system_color Swt::SWT::COLOR_WIDGET_BACKGROUND
    BGCOLOR = [:red, :green, :blue].inject("#") {|str,color| str + SYSTEM_BGCOLOR.send(color).to_s(16) }
  end
  VIEW_ROOT = File.expand_path("../../../views/", __FILE__)

  def render(options, render_options = {})
    if options.respond_to? :to_str
      template = File.join(VIEW_ROOT, "#{options}.haml")
    elsif options[:partial]
      template = File.join(VIEW_ROOT, "partials/_#{options[:partial]}.haml")
      render_options.merge!(options)
    else
      raise ArgumentError, "No partial and no template name given"
    end

    @options = render_options
    Haml::Engine.new(File.read(template)).render(binding)
  end

  # TODO: Hook up colours
  # TODO: Hook up linking
  # XXX: Law-of-demeter
  def process(text, model)
    text = text.to_s.gsub("\n", "<br>").gsub("\t", "&nbsp;" * 2).gsub(" ", "&nbsp;")
    model.process_output(text)
  end
end
