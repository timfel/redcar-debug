require 'gdi/debugger'

class Redcar::GDI::Debugger::GDB < Redcar::GDI::Debugger
  def self.commandline
    "gdb -p "
  end
end
