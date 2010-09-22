class GDI
  class ContextMenu
    class << self 
      def set_breakpoint
        tab = Redcar.app.focussed_window.focussed_notebook.focussed_tab
        debugger.breakpoints << breakpoint
        # TODO: What now? Get the line? The breakpoint?
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
