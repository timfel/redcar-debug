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

  def self.abstract(*symbols)
    symbols.each do |symbol|
      self.class_eval(<<-RUBY)
        def self.#{symbol}
          raise NotImplementedError.new('You must implement #{symbol}.')
        end
      RUBY
    end
  end

  abstract :commandline, :backtrace, :step_into, :step_over, :step_return, :halt,
    :locals, :breakpoints

end

Dir.glob(File.expand_path("../debugger/*.rb", __FILE__)).each {|f| require f }

