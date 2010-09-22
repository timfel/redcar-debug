# Convenience method :try
# Passed to nil it will return, otherwise it'll send the passed message
# with arguments and optional block
class NilClass
  def try(*args)
  end

  def any?
  end
end

class Object
  def try(*args, &block)
    send(args.first, *(args[1..-1]), &block)
  end
end
