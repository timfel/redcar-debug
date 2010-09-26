require 'gdi/debugger/files/jdb_linker'

class GDI
  class Debugger
    class JDB < Base
      Commandline = "jdb -attach "
      Backtrace = "where"
      Locals = "locals"
      Breakpoints = "clear"
      Threads = "threads"
      Evaluate = "print"
      Break = "stop at"

      Breakpoint = Struct.new(:file, :package, :line, :debugger)

      display_name "Java Debugger"
      src_extensions /\.java/
      file_linker = GDI::Debugger::Files::JdbLinker
      html_elements({:partial => "repl"},
          {:partial => "notebook", :windows => [
            {:name => "Backtrace", :id => "backtrace"},
            {:name => "Threads", :id => "threads"} ] },
          {:partial => "notebook", :windows => [
            {:name => "Locals", :id => "locals"},
            {:name => "Breakpoints", :id => "breakpoints"} ] })

      def initialize(output, process)
        super
        automatic_queries
      end

      def automatic_queries
        @process.add_listener(:prompt_ready) do
          if @breakpoint_hit
            [:Backtrace, :Locals, :Breakpoints, :Threads].each do |query|
              output = wait_for(self.class.const_get(query)) {|stdout| prompt_ready? stdout }
              @output.replace(output, query.to_s.downcase)
            end
          end
        end
      end

      # Override default behaviour to transform path to Java packages before setting the breakpoint
      def set_breakpoint(breakpoint)
        breakpoint.package = determine_top_level_package(breakpoint)
        @process.wait_for("#{self.class::Break} #{breakpoint.package}:#{breakpoint.line}") do |stdout|
          prompt_ready? stdout
        end
      end

      # TODO: For Java projects which do not have all their java files in a src/ directory,
      # this will fail. Apply more heuristics to find the package name.
      def determine_top_level_package(breakpoint)
        src_folder = File.join("src", "")
        file = breakpoint.file
        if breakpoint.file.include? src_folder
          file = breakpoint.file.split(src_folder)[1..-1].join
        end
        file.gsub(File::SEPARATOR, ".").gsub(".java", "")
      end

      # Override default behaviour to be able to set instance variable
      def prompt_ready?(stdout)
        breakpoint_hit?(stdout) || (stdout =~ /> $/)
      end

      def breakpoint_hit?(stdout)
        @breakpoint_hit = (stdout =~ /\[[0-9]+\] $/)
      end
    end
  end
end
