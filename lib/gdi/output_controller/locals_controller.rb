class Redcar::GDI::OutputController
  class LocalsController
    def initialize(output_controller, process_controller)
      @output_controller = output_controller
      @process_controller = process_controller

      process_controller.add_listener(:process_halted) { query_locals }
    end

    def query_locals
      output = @process_controller.locals.gsub("\n", "<br>")
      @output_controller.replace(output, "locals")
    end
  end
end
