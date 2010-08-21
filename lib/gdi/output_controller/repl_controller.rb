class Redcar::GDI::OutputController
  class ReplController
    def initialize(output_controller, process_controller)
      @output_controller = output_controller
      @process_controller = process_controller

      output_controller.add_listener(:stdin_ready) {|cmd| input(cmd) }

      process_controller.add_listener(:process_halted) { show_prompt }
      process_controller.add_listener(:process_resumed) { hide_prompt }
      process_controller.add_listener(:process_finished) { hide_prompt }
      process_controller.add_listener(:stdout_ready) {|out| print(out, "stdout") }
      process_controller.add_listener(:stderr_ready) {|out| print(out, "stderr") }
    end

    def execute(*args)
      @output_controller.execute(*args)
    end

    def append(text)
      @output_controller.append(text, "repl")
    end

    # TODO: Hook up colours
    def process(text)
      text.gsub("\n", "<br>")
    end

    def show_prompt
      execute('$("#input").show();$("#input").focus();')
    end

    def hide_prompt
      execute('$("#input").hide();')
    end

    def print(out, cssclass)
      append(<<-HTML)
      <span class="#{cssclass}">#{process(out)}</span>
      HTML
      execute(<<-JAVASCRIPT)
      $("#repl-window").attr({ scrollTop: $("#repl-window").attr("scrollHeight") });
      JAVASCRIPT
    end

    def input(cmd)
      print(process("#{cmd}\n"), "stdout")
      @process_controller.input(cmd)
    end

  end
end