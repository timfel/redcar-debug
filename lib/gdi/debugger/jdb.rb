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
    @process.add_listener(:process_halted) do
      [:Backtrace, :Locals, :Breakpoints, :Threads].each do |query|
        @process.input(self.class.const_get(query))
        output = wait_for {|stdout| prompt_ready? stdout }
        @output.replace(output, query.to_s.downcase)
      end
    end
  end

  def prompt_ready?(stdout)
    stdout =~ /(>|\[[0-9]+\]) $/
  end

  def self.html_elements
    [ {:partial => "repl"},
      {:partial => "notebook", :windows => [
        {:name => "Backtrace", :id => "locals"},
        {:name => "Threads", :id => "threads"} ] },
      {:partial => "notebook", :windows => [
        {:name => "Locals", :id => "locals"},
        {:name => "Breakpoints", :id => "breakpoints"} ] } ]
  end
end
