require 'gdi/process_controller'

class Redcar::GDI::Speedbar < Redcar::Speedbar
  class << self
    attr_accessor :previous_connection
    attr_accessor :previous_arguments
  end

  attr_accessor :model

  def initialize(model)
    p "init with #{model}"
    self.model = model
  end

  def after_draw
    self.connection.value = self.class.previous_connection
    self.arguments.value  = self.class.previous_arguments
  end

  label :label_cmd, "model.command"

  label :label_connection, "Attach to:"
  textbox :connection

  label :label_replace, "Additional arguments:"
  textbox :arguments

  button :run, "Debug!", "Return" do
    self.class.previous_connection  = connection.value
    self.class.previous_arguments   = arguments.value
    run
  end

  def self.run
    ProcessController.new(model)
  end
end
