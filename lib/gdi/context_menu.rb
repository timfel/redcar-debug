class GDI
  class ContextMenu
    class << self 
      def set_breakpoint
        edit_view = Redcar::EditView.current
        if edit_view
          document = edit_view.document
          if document.mirror.is_a? Redcar::Project::FileMirror
            file = document.mirror.path
            line = document.cursor_line
            responsible_debugger = GDI.debuggers.detect {|d| document.title =~ d.src_extensions }

            if responsible_debugger
              breakpoint = GDI::Debugger::Breakpoint.new.tap do |b|
                b.file = file
                b.line = line
                b.debugger = responsible_debugger
              end

              unless responsible_debugger.breakpoints.include? breakpoint
                responsible_debugger.breakpoints << breakpoint

                edit_view.add_annotation_type("gdi.breakpoint.type", :anchor, [32, 64, 245])

                length = document.get_line(line).length
                document.scroll_to_line(line)
                edit_view.add_annotation("gdi.breakpoint.type",
                    line, "#{responsible_debugger.display_name} breakpoint",
                    0, length)

                GDI::Debugger.active_debuggers.detect {|d| document.title =~ d.src_extensions }.try(:set_breakpoints)
              end
            end
          end
        end
      end

      def evaluate
        document = Redcar.app.focussed_window.focussed_notebook.focussed_tab.document
        text = document.try(:selected_text)
        if text.any?
          responsible_debugger = GDI::Debugger.active_debuggers.detect {|d| document.title =~ d.src_extensions }
          if responsible_debugger
            responsible_debugger.process.input "#{responsible_debugger.class::Evaluate} #{text}"
          end
        end
      end
    end
  end
end
