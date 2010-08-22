class Redcar::GDI::Debugger::GDB < Redcar::GDI::Debugger
  Commandline = "gdb -p "
  Backtrace = "bt"
  Locals = "info locals"
  Breakpoints = "info breakpoints"

  def initialize(output, process)
    super
    automatic_queries
  end

  def automatic_queries
    @process.add_listener(:process_halted) do
      [:Backtrace, :Locals, :Breakpoints].each do |query|
        @process.input(self.class.const_get(query))
        output = wait_for {|stdout| prompt_ready? stdout }
        @output.replace(output, query.to_s.downcase)
      end
    end
  end

  def prompt_ready?(stdout)
    stdout.end_with? "(gdb) "
  end

  def self.html_elements
    [ {:partial => "repl"},
      {:partial => "window", :name => "Backtrace", :id => "backtrace"},
      {:partial => "notebook", :windows => [
        {:name => "Locals", :id => "locals"},
        {:name => "Breakpoints", :id => "breakpoints"} ] } ]
  end
end
