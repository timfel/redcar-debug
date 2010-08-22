class Redcar::GDI::OutputController
  class BreakpointsController
    def initialize(output_controller, process_controller)
      @output_controller = output_controller
      @process_controller = process_controller

      process_controller.add_listener(:process_halted) { query_breakpoints }
    end

    def query_breakpoints
      output = @process_controller.breakpoints.gsub("\n", "<br>")
      @output_controller.replace(output, "breakpoints")
    end
  end
end
