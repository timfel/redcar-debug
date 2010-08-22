class Redcar::GDI::OutputController
  class ReplController < Base
    def initialize(output_controller, process_controller)
      super
      add_listeners
    end

    def add_listeners
      @output_controller.add_listener(:stdin_ready) {|cmd| input(cmd) }
      @process_controller.add_listener(:process_halted) { show_prompt }
      @process_controller.add_listener(:process_resumed) { hide_prompt }
      @process_controller.add_listener(:process_finished) { hide_prompt }
      @process_controller.add_listener(:stdout_ready) {|out| print(out, "stdout") }
      @process_controller.add_listener(:stderr_ready) {|out| print(out, "stderr") }
    end

    def show_prompt
      execute('$("#input").show();$("#input").focus();')
    end

    def hide_prompt
      execute('$("#input").hide();')
    end

    def print(out, cssclass)
      append("<span class=\"#{cssclass}\">#{out}</span>", "repl")
      execute(<<-JAVASCRIPT)
      $("#repl-window").attr({ scrollTop: $("#repl-window").attr("scrollHeight") });
      JAVASCRIPT
    end

    def input(cmd)
      print("#{cmd}\n", "stdout")
      @process_controller.input(cmd)
    end
  end
end