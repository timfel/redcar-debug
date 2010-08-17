require 'erb'
require 'gdi/output_controller/repl_controller'
require 'gdi/output_controller/trace_controller'

class Redcar::GDI::OutputController
  include Redcar::HtmlController

  def initialize(process_controller)
    @process_controller = process_controller

    ReplController.new(self, process_controller)
    TraceController.new(self, process_controller)

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
    $("html, body").attr({ scrollTop: $("##{id}").attr("scrollHeight") });
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
    rhtml = ERB.new(File.read(File.expand_path("../../../views/index.html.erb", __FILE__)))
    rhtml.result(binding)
  end

  def input(text)
    @process_controller.input(text)
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
      @tab = Redcar.app.focussed_window.new_tab(Redcar::HtmlTab)
      @tab.html_view.controller = self
    end
    @tab.focus
  end

  def title
    "GDI Session"
  end
end
