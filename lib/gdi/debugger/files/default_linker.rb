require 'gdi/debugger/files/base'

module GDI::Debugger::Files
  class DefaultLinker < Base

    def find_links(text)
      links = []
      while (match_begin = text =~ /(#{file_pattern})/)
        link = add_file_link($1, $2, $3)
        links << link
        text = text[match_begin + link[:match].length..-1]
      end
      links
    end

    # The default file pattern matches full path files with the source
    # extension of the debugger, followed by a colon and a line-number
    def file_pattern
      path_segments = /(?:\/[^:\/]+)+/
      line_number   = /[1-9][0-9]*/
      /(#{path_segments}#{debugger.src_extensions}):(#{line_number})/
    end
  end
end
