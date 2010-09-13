class GDI::Debugger
  module Files
    class Base
      attr_reader :debugger

      # Creates a new linker instance for the given debugger
      # @param GDI::Debugger
      def initialize(debugger)
        @debugger = debugger
      end

      # Find links to files in the textual output
      # @param String
      def find_links(text)
        []
      end

      # Creates a hash from the text that represents a file, the
      # expanded file path and the line number
      # @param String
      # @param String
      # @param String
      def add_file_link(matched_text, file_part, lineno_part)
        { :match => matched_text, :file => file_part, :line => lineno_part }
      end
    end
  end
end