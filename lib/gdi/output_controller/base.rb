class Redcar::GDI::OutputController::Base
  extend Redcar::GDI::Autoloader
  
  def initialize(output_controller, process_controller)
    @output_controller = output_controller
    @process_controller = process_controller
  end
  
  def execute(*args)
    @output_controller.execute(*args)
  end
  
  def append(text, css_id)
    @output_controller.append(text, css_id)
  end
  
  # TODO: Hook up colours
  def process(text)
    text.gsub("\n", "<br>")
  end
end
