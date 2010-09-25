require 'open3'
require 'timeout'
require 'gdi/output_controller'

class GDI::ProcessController
  BUFFER_SIZE = 10000

  include Redcar::Observable

  attr_accessor :model
  attr_accessor :breakpoints

  def initialize(options)
    @output     = GDI::OutputController.new(self)
    @model      = options[:model].new(@output, self)
    @connection = options[:connection]
    @arguments  = options[:arguments]
    @mutex      = Mutex.new

    @output.add_listener(:rerun) { run }
  end

  def close
    notify_listeners(:process_finished)
    @output_thread.kill
    @stdin.close
    @stdout.close
    @stdin = @stdout = nil
  end

  def running?
    @stdout && !@stdout.eof?
  end

  def run
    notify_listeners(:run)
    [:osx, :linux].include? Redcar.platform ? run_posix : run_windows
  end

  # Send a command to the process. Synchronized, as only one
  # thread should be able to execute commands at a time
  def input(text)
    @mutex.synchronize do
      @stdin.puts(text)
      @stdin.flush
    end
  end

  def commandline
    "#{@model.class::Commandline} #{@connection} #{@arguments}"
  end

  def run_posix
    @stdin, @stdout = Open3::popen3("#{commandline} 2>&1")
    @output_thread = Thread.new do
      sleep 1
      begin
        loop do
          # The process is closed if EOF is reached
          close if @stdout.eof?
          # Read at most 10000 bytes. Blocks only if _nothing_ is available
          buf = @stdout.readpartial(BUFFER_SIZE)
          notify_listeners(:stdout_ready, buf)
          if buf.size < BUFFER_SIZE
            notify_listeners(@model.prompt_ready?(buf) ? :prompt_ready : :prompt_blocked)
          end
        end
      rescue Exception => e
        p e.class
        p e.message
        p e.backtrace
      end
    end
  end

  # No windows support, sorry
  def run_windows
    notify_listeners(:stdout, "Sorry, windows is not supported at this time")
  end

  # Override the output thread's behaviour to send it's buffers to us to check
  # against a block. Synchronized to allow only one waiting command at a time.
  def wait_for(cmd)
    @mutex.synchronize do
      @stdin.puts(cmd)
      @stdin.flush
      buffer = @stdout.gets

      loop do
        break if yield(buffer)
        # The next call blocks if no output is available
        buffer += @stdout.readpartial(BUFFER_SIZE)
      end
      buffer
    end
  end
end
