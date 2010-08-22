class Redcar::GDI::OutputController
  extend Redcar::GDI::Autoloader
  include Redcar::GDI::HtmlStyler
  include Redcar::HtmlController
  include Redcar::Observable

  def initialize(process_controller)
    @process_controller = process_controller

    process_controller.add_listener(:run) { start }
    process_controller.add_listener(:process_halted) { status("Halted") }
    process_controller.add_listener(:process_resumed) { status("Running") }
    process_controller.add_listener(:process_finished) { status("Finished") }
  end

  def ask_before_closing
    if @process_controller.running?
      "This tab contains a running debugger. \n\nKill the debugger and close?"
    end
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
    @html_elements = @process_controller.model.class.html_elements
    render("index")
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
