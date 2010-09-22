class GDI::Debugger
  class Gdb < Base
    Commandline = "gdb -p "
    Backtrace = "bt"
    Locals = "info locals"
    Registers = "info reg"
    Breakpoints = "info breakpoints"
    Evaluate = "print"

    display_name "GNU Debugger"
    prompt_ready? {|stdout| stdout.end_with? "(gdb) " }
    src_extensions /\.(?:cpp|c)/
    html_elements({:partial => "repl"},
      {:partial => "window", :name => "Backtrace", :id => "backtrace"},
      {:partial => "notebook", :windows => [
        {:name => "Locals", :id => "locals"},
        {:name => "Registers", :id => "registers"},
        {:name => "Breakpoints", :id => "breakpoints"} ] })

    def initialize(output, process)
      super
      automatic_queries
    end

    def automatic_queries
      process.add_listener(:prompt_ready) do
        [:Backtrace, :Locals, :Breakpoints, :Registers].each do |query|
          process.input(self.class.const_get(query))
          out = wait_for {|stdout| prompt_ready? stdout }
          output.replace(out, query.to_s.downcase)
        end
      end
    end
  end
end
