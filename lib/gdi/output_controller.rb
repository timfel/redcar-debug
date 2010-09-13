require 'gdi/output_helper'
require 'gdi/output_controller/repl_controller'

class GDI
  class  OutputController
    include GDI::OutputHelper
    include Redcar::HtmlController
    include Redcar::Observable

    def initialize(process_controller)
      @process_controller = process_controller

      process_controller.add_listener(:run) { show_tab }
      process_controller.add_listener(:prompt_ready) { status("Ready") }
      process_controller.add_listener(:prompt_blocked) { status("Blocked") }
      process_controller.add_listener(:process_finished) { status("Finished") }
      add_listener(:open_file_request) {|file,line| open_file(file, line.to_i) }
    end

    def ask_before_closing
      if @process_controller.running?
        "This tab contains a running debugger. \n\nKill the debugger and close?"
      end
    end

    def append(text, id)
      execute(<<-JAVASCRIPT)
      $("##{id}").append(#{process(text, model).inspect});
      JAVASCRIPT
    end

    def replace(text, id)
      execute(<<-JAVASCRIPT)
      $("##{id}").html(#{process(text, model).inspect});
      JAVASCRIPT
    end

    def open_file(file, line)
      win = Redcar.app.focussed_window
      win.set_focussed_notebook(win.nonfocussed_notebook)
      Redcar::Project::Manager.open_file(file)
      doc = win.focussed_notebook_tab.edit_view.document
      doc.cursor_offset = doc.offset_at_line(line - 1)
      doc.scroll_to_line(line)
    end

    def close
      @process_controller.close
      @tab = nil
    end

    # XXX: Law-of-demeter
    def model
      @process_controller.model
    end

    def index
      @html_elements = model.class.html_elements
      render("index")
    end

    def input(event, *text)
      notify_listeners(event.to_sym, *text)
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
          w.notebook_orientation = :vertical
          @tab = w.new_tab(Redcar::HtmlTab)
          @tab.html_view.controller = self
        end
      end
      @tab.focus
    end

    def title
      "GDI: #{@process_controller.commandline}"
    end
  end
end
