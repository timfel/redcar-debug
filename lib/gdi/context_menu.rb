require 'gdi/debug_annotation'

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
              breakpoint = responsible_debugger::Breakpoint.new.tap do |b|
                b.file = file
                b.line = line + 1 # indexing starts at 0 for document lines, but not for debuggers
                b.debugger = responsible_debugger
              end

              unless responsible_debugger.breakpoints.include? breakpoint
                responsible_debugger.breakpoints << breakpoint
                DebugAnnotation.add(edit_view, line, :name => responsible_debugger.display_name, :scroll => true)
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
