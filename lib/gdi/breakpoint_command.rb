class GDI
  class BreakpointCommand < Redcar::Command
#    Redcar::Sensitivity.new(:debuggable_source_tab, Redcar.app, false, [:new_tab, :close_tab]) do
#      # checks whether there are any open edit tabs
#      tab = Redcar.app.focussed_notebook_tab
#      if tab.edit_tab?
#        GDI.debuggers.any? {|debugger| tab.title =~ debugger.src_extensions }
#      end
#    end
#
#    sensitize :debuggable_source_tab

    def self.execute
      self.new.execute
    end

    def execute
      tab = Redcar.app.focussed_window.focussed_notebook.focussed_tab
      # TODO: What now? Get the line? The breakpoint?
    end
  end
end
