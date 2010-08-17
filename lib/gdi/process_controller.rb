require 'open3'
require 'gdi/output_controller'

class Redcar::GDI::ProcessController
  include Redcar::Observable

  attr_accessor :model
  attr_accessor :breakpoints

  def initialize(options)
    @model       = options[:model]
    @connection  = options[:connection]
    @arguments   = options[:arguments]
    @breakpoints = Breakpoints.new(self)

    @threads = []

    @awaited_events = {}

    Redcar::GDI::OutputController.new(self)
  end

  def wait_for(*events, &callback)
    events.each {|e| @awaited_events[e] = callback }
  end

  def notify_listeners(symbol, *args)
    if @awaited_events[symbol]
      p "Waited for this event: #{symbol} (#{args}) and now I got it!"
      @awaited_events[symbol].call(args)
      @awaited_events.clear
    else
      super
    end
  end

  def close
    notify_listeners(:process_finished)
    @threads.each {|th| th.kill }
    @threads.clear
    @stdin.close
    @stdout.close
    @stderr.close
    @stdin = @stderr = @stdout = nil
  end

  def running?
    !!@stdin
  end

  def run
    notify_listeners(:run)
    [:osx, :linux].include? Redcar.platform ? run_posix : run_windows

    add_listener(:stdout_ready) do |stdout|
      notify_listeners(stdout.end_with?("\n") ? :process_resumed : :process_halted)
    end
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
    {:stdout_ready => @stdout, :stderr_ready => @stderr}.each_pair do |k, io|
      @threads << Thread.new(io, k) do |io, notification|
        sleep 1
        begin
          loop do
            # The process is closed if EOF is reached
            close if io.eof?
            # Read at most 10000 bytes. Blocks only if _nothing_ is available
            buf = io.readpartial(10000)
            notify_listeners(notification, buf)
          end
        rescue Exception => e
          p e.class
          p e.message
          p e.backtrace
        end
      end
    end
  end

  # No windows support, sorry
  def run_windows
    notify_listeners(:stdout, "Sorry, windows is not supported at this time")
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

  def backtrace(&callback)
    wait_for(:stdout_ready, :stderr_ready, &callback)
    input(model.backtrace)
  end

  def locals(scope=nil)
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
