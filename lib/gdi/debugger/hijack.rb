require 'gdi/debugger'

class Redcar::GDI::Debugger::Hijack < Redcar::GDI::Debugger
  class << self
    def commandline
      "hijack "
    end

    def backtrace
      "NOT SUPPORTED"
    end

    def locals
      "NOT SUPPORTED"
    end

    def breakpoints
      "NOT SUPPORTED"
    end
  end
end
