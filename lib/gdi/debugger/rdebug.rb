class Redcar::GDI::Debugger::RDebug < Redcar::GDI::Debugger
  Commandline = "rdebug -c "
  Backtrace = "backtrace"
  Threads = "info threads"
  Breakpoints = "info breakpoints"
  Variables = "info variables"

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

  def prompt_ready?(stdout)
    stdout =~ /\(rdb:[0-9]+\) $/
  end

  def self.html_elements
    [ {:partial => "repl"},
      {:partial => "window", :name => "Backtrace", :id => "backtrace"},
      {:partial => "notebook", :windows => [
        {:name => "Variables", :id => "variables"},
        {:name => "Threads", :id => "threads"},
        {:name => "Breakpoints", :id => "breakpoints"} ] } ]
  end

  class Hijack < RDebug
    Commandline = "hijack "

    def query(info)
      # Hijack usually starts with an IRB prompt to setup breakpoints
      # At this point we cannot run our info queries
      super unless @irb_prompt
    end

    def prompt_ready?(stdout)
      (@irb_prompt =~ />> $/) || super
    end
  end
end
