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
      [:Backtrace, :Locals, :Breakpoints, :Threads].each do |query|
        @process.input(self.class.const_get(query))
        output = wait_for {|stdout| breakpoint_hit? stdout }
        @output.replace(output, query.to_s.downcase)
      end
    end
  end

  def prompt_ready?(stdout)
    stdout =~ /(>|\[[0-9]+\]) $/
  end

  def breakpoint_hit?(stdout)
    /Breakpoint hit: .*\n+.*\[[0-9]+\] $/m
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
