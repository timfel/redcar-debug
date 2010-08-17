class Redcar::GDI::OutputController
  class TraceController
    def initialize(output_controller, process_controller)
      @output_controller = output_controller
      @process_controller = process_controller
      process_controller.add_listener(:process_halted) { query_trace }
    end
    
    def query_trace      
      @process_controller.backtrace {|output| print_trace(output) }
    end

    def print_trace(output)
      p "Got #{output} as query return"
      @output_controller.replace(output, "trace")
    end
  end
end
