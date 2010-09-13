require 'patches/try'
require 'gdi/breakpoint_command'
require 'gdi/speedbar'

module Redcar
  class GDI
    class << self
      def debuggers
        @debuggers ||= []
      end

      def menus
        Menu::Builder.build do
          sub_menu "Debug" do
            sub_menu "GDI" do
              Redcar::GDI.debuggers.each do |p|
                item(p.display_name) { Redcar::GDI.execute(p) }
              end
            end
          end
        end
      end

      def edit_view_context_menus
        Menu::Builder.build do
          group(:priority => 50) do
            item "Set breakpoint", :command => Redcar::GDI::BreakpointCommand
          end
        end
      end

      def storage
      end

      def execute(model)
        @speedbar = Redcar::GDI::Speedbar.new(model)
        Redcar.app.focussed_window.open_speedbar(@speedbar)
      end
    end
  end
end

require 'gdi/debugger'

