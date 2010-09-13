require 'gdi/output_helper'

class GDI::OutputController
  class Base
    include GDI::OutputHelper

    def initialize(output_controller, process_controller)
      @output_controller = output_controller
      @process_controller = process_controller
    end

    def execute(*args)
      @output_controller.execute(*args)
    end

    def append(*args)
      @output_controller.append(*args)
    end
  end
end
