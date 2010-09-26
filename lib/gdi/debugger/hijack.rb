require 'gdi/debugger/rdebug'

# Hijack forces rdebug into a process first-thing.
# It differs from plain RDebug only in that it first
# displays an IRB prompt which is not for debugging,
# but for setting breakpoints
class GDI
  class Debugger
    class Hijack < RDebug
      Commandline = "hijack "

      display_name "Hijack for MRI"

      def query(info)
        # If we're at an irb prompt, we cannot run our info queries
        super unless @irb_prompt
      end

      # Overwrite default behaviour to get instance state behaviour
      def prompt_ready?(stdout)
        (@irb_prompt =~ />> $/) || super
      end
    end
  end
end
