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
  abstract :"prompt_ready?", :"self.html_elements"

end

Dir.glob(File.expand_path("../debugger/*.rb", __FILE__)).each {|f| require f }
