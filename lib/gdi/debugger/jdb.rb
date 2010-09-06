class Redcar::GDI::Debugger::JDB < Redcar::GDI::Debugger
  Commandline = "jdb -attach "
  Backtrace = "where"
  Locals = "locals"
  Breakpoints = "clear"
  Threads = "threads"

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

  def prompt_ready?(stdout)
    breakpoint_hit?(stdout) || (stdout =~ /> $/)
  end

  def breakpoint_hit?(stdout)
    @breakpoint_hit = (stdout =~ /\[[0-9]+\] $/)
  end

  def src_extension
    /\.java/
  end

  def self.html_elements
    [ {:partial => "repl"},
      {:partial => "notebook", :windows => [
        {:name => "Backtrace", :id => "backtrace"},
        {:name => "Threads", :id => "threads"} ] },
      {:partial => "notebook", :windows => [
        {:name => "Locals", :id => "locals"},
        {:name => "Breakpoints", :id => "breakpoints"} ] } ]
  end
end
