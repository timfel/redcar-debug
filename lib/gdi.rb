module Redcar
  class GDI
    module Autoloader
      LIB_PATH = File.expand_path("../../", __FILE__)

      def class2path(klass)
        klass.to_s.gsub("Redcar::", "").gsub("::", "/").gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      end

      def require_without_load_error(path)
        require(path)
      rescue LoadError
      end

      # Simple auto-loading for fully qualified classes
      def const_missing(symbol)
        path = class2path(symbol)
        klass = const_get(symbol) if require_without_load_error(path)

        unless klass
          path = class2path("#{self.name}::#{symbol.to_s}")
          klass = const_get(symbol) if require_without_load_error(path)
        end

        raise NameError, "Class #{symbol} not found" unless klass
        klass
      end
    end

    class << self
      include Autoloader

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

