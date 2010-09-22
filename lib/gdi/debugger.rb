require 'gdi/debugger/files/default_linker'

class GDI
  class Debugger
    class << self
      @@active_debuggers = []

      def active_debuggers
        @@active_debuggers
      end

      # Subscribe each subclass to the GDI plugin
      def inherited(clazz)
        GDI.debuggers << clazz
        super(clazz)
      end

      # Allow inheriting class attributes
      def get_inherited_attribute(attr)
        if var = instance_variable_get(attr)
          return var
        end
        superclass.get_inherited_attribute(attr) unless superclass == GDI::Debugger
      end

      # Tries using the passed object as a String or a Proc
      # If it is nil, return nil, if none of these conditions apply, return obj.inspect
      def return_or_call(obj)
        return if obj.nil?
        case obj
        when String then obj
        when Symbol then self.send(obj)
        when Proc then obj.call
        else "#{obj}"
        end
      end

      # Class instance variable to keep track of breakpoints to set on debug-start.
      # These breakpoints can be set on a file and will be added to each debugger instance
      def breakpoints
        @breakpoints ||= []
      end

      # The name for display in the menu
      # Inherited
      def display_name(name = nil)
        name ? @name = name : return_or_call(get_inherited_attribute("@name"))
      end

      # A proc to determine whether the prompt is ready for a given debugger
      # Inherited
      def prompt_ready?(stdout=nil)
        @prompt_ready = Proc.new if block_given?
        if stdout
          get_inherited_attribute("@prompt_ready").try(:call, stdout)
        end
      end

      # An array with html element definitions (as hashes)
      # Inherited
      def html_elements(*elements)
        elements.any? ? @html_elements = elements : get_inherited_attribute("@html_elements")
      end

      # The class to use for linking files to textual output.
      # Inherited
      def file_linker(klass = nil)
        klass ? @file_linker = klass : get_inherited_attribute("@file_linker")
      end

      # A regex or string to match the extensions of src files debugged by this debugger
      # Inherited
      def src_extensions(extensions = nil)
        extensions ? @src_extensions = extensions : get_inherited_attribute("@src_extensions")
      end

      # A hook to apply processing before displaying the debuggers output.
      # Inherited
      def before_output(*symbols)
        if symbols.empty?
          chain = []
          chain += superclass.before_output unless superclass == GDI::Debugger
          return chain + (@before_output_chain || [])
        end
        @before_output_chain = (@before_output_chain || []) + symbols
      end

      # Mark this class as abstract
      def abstract!
        GDI.debuggers.delete(self)
      end
    end

    attr_reader :output, :process

    def initialize(output, process)
      @@active_debuggers << self
      @process = process
      @output = output
      @file_linker = self.class.file_linker.new(self)

      @process.add_listener(:process_finished) { @@active_debuggers.delete(self) }
    end

    def wait_for(&block)
      process.wait_for(&block)
    end

    def prompt_ready?(stdout)
      self.class.prompt_ready?(stdout)
    end

    def process_output(text)
      self.class.before_output.inject(text) do |txt, method|
        self.send(method.to_sym, txt)
      end
    end

    def src_extensions
      self.class.src_extensions
    end
  end
end

Dir.glob(File.expand_path("../debugger/*.rb", __FILE__)).each {|f| require f }
