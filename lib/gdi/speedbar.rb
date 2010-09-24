require 'gdi/process_controller'

class GDI::Speedbar < Redcar::Speedbar
  class << self
    attr_accessor :previous_connection
    attr_accessor :previous_arguments
  end

  attr_accessor :model
  
  def self.connection_widgets(auto_connecting = true)
    items.clear
    label :label, "Running:"
    label :label_cmd, "model.command"

    unless auto_connecting
      label :label_connection, "Attach to:"
      textbox :connection
    end

    label :label_replace, "Additional arguments:"
    textbox :arguments

    button :button_debug, "Debug!", "Return" do
      connection_value = (" " if model.auto_connecting?) || connection.value
      unless connection_value.empty?
        self.class.previous_connection = connection.value
        self.class.previous_arguments  = arguments.value
        debug(connection.value, arguments.value)
      else
        connection.value = "--- Need a value"
      end
    end
  end

  def initialize(model)
    self.class.connection_widgets(model.auto_connecting?)

    super()
    self.model = model
    label_cmd.text = model::Commandline
  end

  def after_draw
    connection.value = self.class.previous_connection || ""
    arguments.value  = self.class.previous_arguments || ""
  end

  def debug(connection, arguments)
    GDI::ProcessController.new(:model => model,
      :arguments => arguments,
      :connection => connection).run
    controller.close
  end
end
