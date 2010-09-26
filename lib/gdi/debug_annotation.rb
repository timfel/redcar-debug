class GDI
  class DebugAnnotation
    Name  = "gdi.breakpoint.type"
    Icon  = "control-pause"
    Color = [32, 32, 32]

    class << self
      def initialize
        super
        edit_view_listener
      end

      def edit_view_listener
        Redcar::EditView.add_listener(:focussed_edit_view) do |edit_view|
          if edit_view.document.mirror.is_a? Redcar::Project::FileMirror
            responsible_debugger = GDI.debuggers.detect {|d| edit_view.document.title =~ d.src_extensions }
            if responsible_debugger
              breakpoints = responsible_debugger.breakpoints.select {|b| b.file == edit_view.document.mirror.path }
              breakpoints.each do |b|
                add(edit_view, b.line, :name => responsible_debugger.display_name)
              end
            end
          end
        end
      end

      def add(edit_view, line, options = {})
        edit_view.add_annotation_type(Name, Icon, Color)
        edit_view.document.scroll_to_line(line) if options[:scroll]
        edit_view.add_annotation(Name, line, "#{options[:name]} breakpoint", 0, 0)
      end
    end
  end
end