require File.expand_path("../../../vendor/haml/lib/haml", __FILE__)

require 'gdi/output_controller/repl_controller'
require 'gdi/output_controller/trace_controller'
require 'gdi/output_controller/locals_controller'
require 'gdi/html_styler'

class Redcar::GDI::OutputController
  include Redcar::HtmlController
  include Redcar::Observable
  include HtmlStyler

  def initialize(process_controller)
    @process_controller = process_controller

    ReplController.new(self, process_controller)
    TraceController.new(self, process_controller)
    LocalsController.new(self, process_controller)

    process_controller.add_listener(:run) { start }
    process_controller.add_listener(:process_halted) { status("Halted") }
    process_controller.add_listener(:process_resumed) { status("Running") }
    process_controller.add_listener(:process_finished) { status("Finished") }
  end

  def ask_before_closing
    "This tab contains a running debugger. \n\nKill the debugger and close?"
  end

  def append(text, id)
    execute(<<-JAVASCRIPT)
    $("##{id}").append(#{text.inspect});
    JAVASCRIPT
  end

  def replace(text, id)
    execute(<<-JAVASCRIPT)
    $("##{id}").html(#{text.inspect});
    JAVASCRIPT
  end

  def close
    @process_controller.close
    @tab = nil
  end

  def index
    rhtml = Haml::Engine.new(File.read(File.expand_path("../../../views/index.haml", __FILE__)))
    rhtml.render(binding)
  end

  def input(event, text)
    notify_listeners(event.to_sym, text)
  end

  def start
    show_tab
  end

  def status(text)
    replace(<<-HTML, "status")
    <small><strong>#{text}</strong></small>
    <hr />
    HTML
  end

  def show_tab
    unless @tab
      Redcar.app.focussed_window.tap do |w|
        # Ensure two notebooks, focus the currently unfocused one
        w.create_notebook
        w.set_focussed_notebook(w.nonfocussed_notebook)
        @tab = w.new_tab(Redcar::HtmlTab)
        @tab.html_view.controller = self
      end
    end
    @tab.focus
  end

  def title
    "GDI Session"
  end
end
