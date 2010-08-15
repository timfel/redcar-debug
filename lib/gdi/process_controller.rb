module Redcar
  class  GDI
    class ProcessController
      attr_accessor :debugger_model
      attr_accessor :breakpoints

      def initialize(model)
        @debugger_model = model
        @breakpoints = Breakpoints.new(self)
      end

      # TODO: Wrap closing of notebook etc.
      def close
        super
      end

      def running?
        !!@shell
      end

      def run
        unless running?
          @tab = Redcar.app.focussed_window.new_tab(HtmlTab)
          @tab.html_view.controller = controller
          @tab.focus
        else
          @tab.focus
        end
      end

      def run_posix
        @thread = Thread.new do
          sleep 1
          @shell = Session::Shell.new
          @shell.outproc = lambda do |out|
            html=<<-HTML
            <div class="stdout">
            #{process(out)}
            </div>
            HTML
            execute(<<-JAVASCRIPT)
            $("#output").append(#{html.inspect});
            $("html, body").attr({ scrollTop: $("#output").attr("scrollHeight") });
            JAVASCRIPT
          end
          @shell.errproc = lambda do |err|
            html=<<-HTML
            <div class="stderr">
            <pre>#{err}</pre>
            </div>
            HTML
            execute(<<-JAVASCRIPT)
            $("#output").append(#{html.inspect});
            $("html, body").attr({ scrollTop: $("#output").attr("scrollHeight") });
            JAVASCRIPT
          end
          begin
            @shell.execute("gdb")
          rescue => e
            puts e.class
            puts e.message
            puts e.backtrace
          end
          html=<<-HTML
          <hr />
          <small><strong>Process finished</strong></small>
          HTML
          execute(<<-JAVASCRIPT)
          $("#output").append(#{html.inspect});
          $("html, body").attr({ scrollTop: $("#output").attr("scrollHeight") });
          JAVASCRIPT
          @shell = nil
          @thread = nil
        end
      end

      # No windows support, sorry
      def run_windows
        html=<<-HTML
        <div class="stdout">
        Sorry, windows is not supported at this time
        </div>
        HTML
      end

      # Step to next line in current file
      def step_over
      end

      # Step into the next function
      def step_into
      end

      # Return from of the current function
      def step_return
      end

      # Stop NOW
      def halt
      end

      def halted
        @shell
      end

      def add_breakpoint(element)
        @debugger_model.add_breakpoint(element)
      end

      class Breakpoints < Array
        def initialize(controller)
          @model = controller
          super()
        end

        def << element
          @model.add_breakpoint(element)
          super(element)
        end
      end
    end

  end
end
