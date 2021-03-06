class GDI
  class Debugger
    class RDebug < Base
      Commandline = "rdebug -c "
      Backtrace = "backtrace"
      Threads = "info threads"
      Breakpoints = "info breakpoints"
      Variables = "info variables"
      Evaluate = "p"
      Break = "break"

      auto_connecting!
      display_name "Ruby Debug"
      prompt_ready? {|stdout| (stdout =~ /\(rdb:[A-Za-z0-9]+\)\s+$/) }
      src_extensions /\.(?:rb|rhtml|html\.erb)/
      html_elements({:partial => "repl"},
        {:partial => "window", :name => "Backtrace", :id => "backtrace"},
        {:partial => "notebook", :windows => [
          {:name => "Variables", :id => "variables"},
          {:name => "Threads", :id => "threads"},
          {:name => "Breakpoints", :id => "breakpoints"} ] })

      def initialize(output, process)
        super
        automatic_queries
      end

      def automatic_queries
        @process.add_listener(:prompt_ready) do
          [:Backtrace, :Threads, :Breakpoints, :Variables].each {|info| query(info) }
        end
      end

      def query(info)
        output = wait_for(self.class.const_get(info)) {|stdout| prompt_ready? stdout }
        @output.replace(output, info.to_s.downcase)
      end
    end
  end
end
