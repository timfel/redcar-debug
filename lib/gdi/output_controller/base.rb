class Redcar::GDI::OutputController::Base
  extend Redcar::GDI::Autoloader
  include Redcar::GDI::OutputHelper
  
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
