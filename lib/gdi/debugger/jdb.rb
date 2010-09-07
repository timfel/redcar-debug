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

  # FIXME: Don't just use Dir.glob, open the FindFileDialog, if necessary
  def add_file_link(matched_text, file_part, lineno_part)
    Redcar::GDI::FileLink.new.tap do |l|
      l.match = matched_text
      if lineno_part
        # Line breakpoint
        file_part = "#{File.join(file_part.split("."))}.java"
        l.line = lineno_part
      else
        # Method breakpoint, exclude method
        parts = file_part.split(".")
        file_part = "#{File.join(parts[0...-1])}.java"
        l.line = 1
        method= parts.last # TODO: Jump to method, not to top
      end
      l.file = Dir.glob(File.join(Project::Manager.focussed_project.path, "**", file_part)).first
    end
  end

  def file_pattern
    path_segment  = /[A-Za-z\$0-9]+/
    path_segments = /(?:#{path_segment}\.)+/
    line_number   = /[1-9][0-9]*/
    /(#{path_segments}#{path_segment})(?::(#{line_number}))?/
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
