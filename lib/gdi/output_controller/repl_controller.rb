require 'gdi/output_controller/base'

class GDI::OutputController
  class ReplController < Base
    attr_reader :cmd_history

    def initialize(output_controller, process_controller)
      super
      @cmd_history = UndoStack.new
      add_listeners
    end

    def add_listeners
      @output_controller.add_listener(:stdin_ready) {|cmd| input(cmd) }
      @output_controller.add_listener(:stdin_keypress) {|key| keypress(key) }
      @output_controller.add_listener(:rerun) { show_prompt }

      @process_controller.add_listener(:prompt_ready) { show_prompt }
      @process_controller.add_listener(:prompt_blocked) { hide_prompt }
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
      cmd_history << cmd
      @process_controller.input(cmd)
    end

    def keypress(key)
      cmd = case key
            when "up" then cmd_history.up
            when "down" then cmd_history.down
            end
      execute(<<-JAVASCRIPT)
      $("#input")[0].value = "#{cmd}";
      JAVASCRIPT
    end

    class UndoStack
      MAX_LENGTH = 100

      def initialize
        @position = 0
        @stack = []
      end

      def << item
        @stack << item
        @stack = @stack[1..-1] if @stack.length > MAX_LENGTH
        @position = @stack.length
      end

      def move(length)
        @position = (@position + length) % (@stack.length + 1)
        @stack[@position]
      end

      def up
        move(-1)
      end

      def down
        move(1)
      end
    end
  end
end
