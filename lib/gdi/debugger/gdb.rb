require 'gdi/debugger'

class Redcar::GDI::Debugger::GDB < Redcar::GDI::Debugger
  def command
    "gdb -p "
  end
end
