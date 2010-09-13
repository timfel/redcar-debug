require 'gdi/debugger/files/default_linker'

class Redcar::GDI
  class Debugger
    class << self
      # Subscribe each subclass to the GDI plugin
      def inherited(clazz)
        Redcar::GDI.debuggers << clazz
        super(clazz)
      end

      @breakpoints = []
      # Class instance variable to keep track of breakpoints to set on debug-start.
      # These breakpoints can be set on a file and will be added to each debugger instance
      def breakpoints
        @breakpoints
      end

      # The name for display in the menu. Defaults to classname
      def display_name(name = nil)
        name ? @@name = name : self.name
      end

      # A proc to determine whether the prompt is ready for a given debugger
      def prompt_ready?(stdout=nil)
        @prompt_ready = Proc.new if block_given?
        @prompt_ready.try(:call, stdout) if stdout
      end

      # An array with html element definitions (as hashes)
      def html_elements(*elements)
        elements.any? ? @html_elements = elements : @html_elements ||= []
      end

      # The class to use for linking files to textual output
      def file_linker(klass = nil)
        klass ? @file_linker = klass : @file_linker ||= Files::DefaultLinker
      end

      # A regex or string to match the extensions of src files debugged by this debugger
      def src_extensions(extensions = nil)
        extensions ? @src_extensions = extensions : @src_extensions
      end
    end

    attr_reader :output, :process

    def initialize(output, process)
      @process = process
      @output = output
      @file_linker = self.class.file_linker.new(self)
    end

    def wait_for(&block)
      process.wait_for(&block)
    end

    def prompt_ready?(stdout)
      self.class.prompt_ready?(stdout)
    end

    def find_links(text)
      @file_linker.find_links(text)
    end

    def src_extensions
      self.class.src_extensions
    end
  end
end

Dir.glob(File.expand_path("../debugger/*.rb", __FILE__)).each {|f| require f }
