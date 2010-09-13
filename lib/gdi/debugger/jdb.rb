require 'gdi/debugger/files/jdb_linker'

class GDI::Debugger
  class JDB < Base
    Commandline = "jdb -attach "
    Backtrace = "where"
    Locals = "locals"
    Breakpoints = "clear"
    Threads = "threads"

    src_extensions /\.java/
    file_linker = GDI::Debugger::Files::JdbLinker
    html_elements({:partial => "repl"},
        {:partial => "notebook", :windows => [
          {:name => "Backtrace", :id => "backtrace"},
          {:name => "Threads", :id => "threads"} ] },
        {:partial => "notebook", :windows => [
          {:name => "Locals", :id => "locals"},
          {:name => "Breakpoints", :id => "breakpoints"} ] })

    def initialize(output, process)
      super
      automatic_queries
    end

    def automatic_queries
      @process.add_listener(:prompt_ready) do
        if @breakpoint_hit
          [:Backtrace, :Locals, :Breakpoints, :Threads].each do |query|
            @process.input(self.class.const_get(query))
            output = wait_for {|stdout| prompt_ready? stdout }
            @output.replace(output, query.to_s.downcase)
          end
        end
      end
    end

    # Overwrite default behaviour to be able to set instance variable
    def prompt_ready?(stdout)
      breakpoint_hit?(stdout) || (stdout =~ /> $/)
    end

    def breakpoint_hit?(stdout)
      @breakpoint_hit = (stdout =~ /\[[0-9]+\] $/)
    end
  end
end
