require 'open3'
require 'gdi/output_controller'

class Redcar::GDI::ProcessController
  attr_accessor :model
  attr_accessor :breakpoints

  def initialize(options)
    @model       = options[:model]
    @connection  = options[:connection]
    @arguments   = options[:arguments]
    @breakpoints = Breakpoints.new(self)
  end

  def close
    output.finish
    @threads.each {|th| th.kill }
    @stdin.close
    @stdout.close
    @stderr.close
  end

  def running?
    !!@stdin
  end

  def run
    output.start
    case Redcar.platform
    when :osx, :linux
      run_posix
    when :windows
      run_windows
    end
  end

  def output
    @output ||= Redcar::GDI::OutputController.new(self)
  end

  def input(text)
    @stdin.puts(text)
    @stdin.flush
  end

  def process(text)
    text
  end

  def run_posix
    @stdin, @stdout, @stderr = Open3::popen3("#{@model.commandline} #{@connection} #{@arguments}")
    @threads = []
    @threads << Thread.new do
      sleep 1
      loop do
        # Read at most 10000 bytes. Blocks if nothing available
        out = @stderr.readpartial(10000)
        output.stderr(out)
      end
    end
    @threads << Thread.new do
      sleep 1
      loop do
        out = @stdout.readpartial(10000)
        output.stdout(out)
        if out.end_with? "\n"
          # No prompt, so we are hanging
          output.hide_prompt
        else
          output.show_prompt
        end
      end
    end
    @threads << Thread.new do
      sleep 1
      close if (@stdout.eof? || @stderr.eof?)
    end
  end

  # No windows support, sorry
  def run_windows
    output.stdout("Sorry, windows is not supported at this time")
  end

  # Step to next line in current file
  def step_over
  end

  # Step into the next function
  def step_into
  end

  # Return from of the current function
  def step_return
  end

  # Stop NOW
  def halt
  end

  def halted
    @shell
  end

  def add_breakpoint(element)
    @debugger_model.add_breakpoint(element)
  end

  class Breakpoints < Array
    def initialize(controller)
      @model = controller
      super()
    end

    def << element
      @model.add_breakpoint(element)
      super(element)
    end
  end
end
