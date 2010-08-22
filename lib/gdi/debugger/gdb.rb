require 'gdi/debugger'

class Redcar::GDI::Debugger::GDB < Redcar::GDI::Debugger
  class << self
    def commandline
      "gdb -p "
    end

    def backtrace
      "bt"
    end

    def locals
      "info locals"
    end

    def breakpoints
      "info breakpoints"
    end
  end
end
