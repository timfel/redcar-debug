require 'open3'
require 'timeout'
require 'gdi/output_controller'

class Redcar::GDI::ProcessController
  BUFFER_SIZE = 10000
  COMMAND_TIMEOUT = 10

  include Redcar::Observable

  attr_accessor :model
  attr_accessor :breakpoints

  def initialize(options)
    @output      = Redcar::GDI::OutputController.new(self)
    @model       = options[:model].new(@output, self)
    @connection  = options[:connection]
    @arguments   = options[:arguments]
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

  def input(text)
    @stdin.puts(text)
    @stdin.flush
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

  def wait_for
    buffer = @stdout.gets

    catch (:output_ready) do
      loop do
        # Wait for output
        begin
          timeout(COMMAND_TIMEOUT) do
            buffer += @stdout.readpartial(BUFFER_SIZE)
          end
        rescue Timeout::Error
        end
        if yield(buffer)
          throw :output_ready
        else
          # Command output has not finished
          # Let JRuby pump the stdout of the process and wait for more
          Thread.pass
        end
      end
    end

    buffer
  end
end
