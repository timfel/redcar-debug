class Redcar::GDI::Debugger
  extend Redcar::GDI::Autoloader

  def initialize(output, process)
    @process = process
    @output = output
    Redcar::GDI::OutputController::ReplController.new(output, process)
  end

  def wait_for(&block)
    @process.wait_for(&block)
  end

  # Find links to files in the textual output
  def find_links(text)
    links = []
    while (match_begin = text =~ /(#{file_pattern})/)
      links << Redcar::GDI::FileLink.new.tap do |l|
        l.match = $1
        l.file = $2
        l.line = $3
      end
      text = text[match_begin + links.last.match.length..-1]
    end
    links
  end

  # The default file pattern matches full path files with the source
  # extension of the debugger, followed by a colon and a line-number
  def file_pattern
    path_segments = /(?:\/[^:\/]+)+/
    line_number   = /[1-9][0-9]*/
    /(#{path_segments}#{src_extension}):(#{line_number})/
  end

  class << self
    # Subscribe each subclass to the plugin
    def inherited(clazz)
      Redcar::GDI.debuggers << clazz
      super(clazz)
    end

    def name
      super.split("::").last
    end

    def abstract(*symbols)
      symbols.each do |symbol|
        self.class_eval(<<-RUBY)
        def #{symbol}
          raise NotImplementedError.new('You must implement #{symbol}.')
        end
        RUBY
      end
    end

  end

  # Interface contract for debugger models
  abstract :"prompt_ready?", :"self.html_elements", :src_extension
end

Dir.glob(File.expand_path("../debugger/*.rb", __FILE__)).each {|f| require f }
