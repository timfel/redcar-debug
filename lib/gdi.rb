require 'patches/try'
require 'gdi/breakpoint_command'
require 'gdi/speedbar'

class GDI
  class << self
    def debuggers
      @debuggers ||= []
    end

    def menus
      Redcar::Menu::Builder.build do
        sub_menu "Debug" do
          sub_menu "GDI" do
            GDI.debuggers.each do |p|
              item(p.display_name) { GDI.execute(p) }
            end
          end
        end
      end
    end

    def edit_view_context_menus
      Redcar::Menu::Builder.build do
        group(:priority => 50) do
          item("Set breakpoint") { GDI::BreakpointCommand.execute }
        end
      end
    end

    def storage
    end

    def execute(model)
      @speedbar = GDI::Speedbar.new(model)
      Redcar.app.focussed_window.open_speedbar(@speedbar)
    end
  end
end

require 'gdi/debugger'

