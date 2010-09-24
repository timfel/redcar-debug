class GDI::Debugger
  class RDebug < Base
    Commandline = "rdebug -c "
    Backtrace = "backtrace"
    Threads = "info threads"
    Breakpoints = "info breakpoints"
    Variables = "info variables"
    Evaluate = "p"

    auto_connecting!
    display_name "Ruby Debug"
    prompt_ready? {|stdout| stdout =~ /\(rdb:[0-9]+\) $/ }
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
      @process.input(self.class.const_get(info))
      output = wait_for {|stdout| prompt_ready? stdout }
      @output.replace(output, info.to_s.downcase)
    end
  end
end
