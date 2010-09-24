require 'gdi/process_controller'

class GDI::Speedbar < Redcar::Speedbar
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
      connection_value = (" " if auto_connecting) || connection.value
      unless connection_value.empty?
        debug(:connection => connection_value, :arguments => arguments.value)
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
    if model.previous_connection
      unless model.auto_connecting?
        connection.value = model.previous_connection[:connection]
      end
      arguments.value  = model.previous_connection[:arguments]
    end
  end

  def debug(options)
    model.previous_connection = options
    GDI::ProcessController.new(options.merge(:model => model)).run
    controller.close
  end
end
