require 'gdi/process_controller'

class Redcar::GDI::Speedbar < Redcar::Speedbar
  class << self
    attr_accessor :previous_connection
    attr_accessor :previous_arguments
  end

  attr_accessor :model

  def initialize(model)
    super()
    self.model = model
    label_cmd.text = model.commandline
  end

  def after_draw
    connection.value = self.class.previous_connection || ""
    arguments.value  = self.class.previous_arguments || ""
  end

  label :label, "Running:"
  label :label_cmd, "model.command"

  label :label_connection, "Attach to:"
  textbox :connection

  label :label_replace, "Additional arguments:"
  textbox :arguments

  button :button_debug, "Debug!", "Return" do
    unless connection.value.empty?
      self.class.previous_connection = connection.value
      self.class.previous_arguments  = arguments.value
      debug(connection.value, arguments.value)
    else
      connection.value = "--- Need a value"
    end
  end

  def debug(connection, arguments)
    Redcar::GDI::ProcessController.new(:model => model,
      :arguments => arguments,
      :connection => connection).run
    controller.close
  end
end
