class Redcar::GDI::Debugger
  extend Redcar::GDI::Autoloader

  def initialize(output, process)
    @process = process
    @output = output
    Redcar::GDI::OutputController::ReplController.new(output, process)
  end

  def wait_for(&block)
    @process.wait_for(&block)
  end

  class << self
    # Subscribe each subclass to the plugin
    def inherited(clazz)
      Redcar::GDI.debuggers << clazz
      super(clazz)
    end

    def name
      super.split("::").last
    end
  end
end

Dir.glob(File.expand_path("../debugger/*.rb", __FILE__)).each {|f| require f }
