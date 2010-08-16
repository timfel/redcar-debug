require 'erb'

class Redcar::GDI::OutputController
  include Redcar::HtmlController

  attr_accessor :tab
  
  def initialize(process_controller)
    @process_controller = process_controller
  end
  
  def ask_before_closing
    "This tab contains a running debugger. \n\nKill the debugger and close?"
  end
  
  def close
    @process_controller.close
    tab = nil
  end
  
  def start
    show_tab
  end
  
  def finish
    append(<<-HTML)    
      <hr />
      <small><strong>Session finished</strong></small>
    HTML
  end
    
  def show_tab
    unless tab
      tab = Redcar.app.focussed_window.new_tab(Redcar::HtmlTab)
      tab.html_view.controller = self
    end
    tab.focus
  end
  
  # TODO: Hook up colours
  def process(text)    
    text.gsub("\n", "<br>")
  end

  def stdout(out)
    append(<<-HTML)
      <span class="stdout">#{process(out)}</span>
    HTML
  end

  def stderr(err)
    append(<<-HTML)
      <span class="stderr">#{process(err)}</span>
    HTML
  end

  def append(text, id = "output")
    execute(<<-JAVASCRIPT)
      $("##{id}").append(#{text.inspect});
      $("html, body").attr({ scrollTop: $("##{id}").attr("scrollHeight") });
    JAVASCRIPT
  end

  def index
    rhtml = ERB.new(File.read(File.expand_path("../../../views/index.html.erb", __FILE__)))        
    rhtml.result(binding)
  end

  def input(text)
    @process_controller.input(text)    
  end

  def title
    "GDI Session"
  end

  def show_prompt
    execute('$("#input").show();$("#input").focus();')
  end

  def hide_prompt
    execute('$("#input").hide();')
  end
end
