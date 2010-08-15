require 'gdi/speedbar'

class Redcar::GDI::Debugger

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

  def commandline
    raise NotImplementedError.new("You must implement command.")
  end

end

Dir.glob(File.expand_path("../debugger/*.rb", __FILE__)).each {|f| require f }

