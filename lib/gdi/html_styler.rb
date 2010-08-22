class Redcar::GDI::OutputController
  module HtmlStyler
    SYSTEM_BGCOLOR = Swt::Widgets::Display.current.system_color Swt::SWT::COLOR_WIDGET_BACKGROUND
    VIEW_ROOT = File.expand_path("../../../views/", __FILE__)
    BGCOLOR = [:red, :green, :blue].inject("#") {|str,color| str + SYSTEM_BGCOLOR.send(color).to_s(16) }
  end
end

