module Redcar::GDI::Debugger::Files
  class JdbLinker < DefaultLinker

    # The JDB file pattern matches class paths, followed either by a colon
    # and a line number, or by a dot and a method name
    def file_pattern
      path_segment  = /[A-Za-z\$0-9]+/
      path_segments = /(?:#{path_segment}\.)+/
      line_number   = /[1-9][0-9]*/
      /(#{path_segments}#{path_segment})(?::(#{line_number}))?/
    end

    # FIXME: Don't just use Dir.glob, open the FindFileDialog, if necessary
    def add_file_link(matched_text, file_part, lineno_part)
      match = matched_text
      if lineno_part
        # Line breakpoint
        file_part = "#{File.join(file_part.split("."))}.java"
        line = lineno_part
      else
        # Method breakpoint, exclude method
        parts = file_part.split(".")
        file_part = "#{File.join(parts[0...-1])}.java"
        line = 1
        method= parts.last # TODO: Jump to method, not to top
      end
      file = Dir.glob(File.join(Project::Manager.focussed_project.path, "**", file_part)).first
      super(match, file, line)
    end
  end
end
