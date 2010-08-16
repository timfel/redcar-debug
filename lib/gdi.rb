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
                item(p.name) { Redcar::GDI.execute(p) }
              end
            end
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

