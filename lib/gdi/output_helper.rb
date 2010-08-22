require File.expand_path("../../../vendor/haml/lib/haml", __FILE__)

module Redcar::GDI::OutputHelper
  SYSTEM_BGCOLOR = Swt::Widgets::Display.current.system_color Swt::SWT::COLOR_WIDGET_BACKGROUND
  VIEW_ROOT = File.expand_path("../../../views/", __FILE__)
  BGCOLOR = [:red, :green, :blue].inject("#") {|str,color| str + SYSTEM_BGCOLOR.send(color).to_s(16) }

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
  def process(text)
    text.to_s.gsub("\n", "<br>")
  end
end