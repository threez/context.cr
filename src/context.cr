require "log"

class Fiber
  # :nodoc:
  getter value_context : Log::Metadata { Log::Metadata.empty }

  # adds the passed key-value pairs to the current fiber context.
  # The values are only accessible in the context of the passed block.
  # The values can be shadowed by calling `with_values` nested.
  def with_values(**kwargs, &)
    previous = value_context
    new_metadata = previous.not_nil!.extend(kwargs) unless kwargs.empty?
    begin
      @value_context = new_metadata
      yield
    ensure
      @value_context = previous
    end
  end

  # adds the passed key-value pairs to the current fiber context without
  # inherinting the previous context values.
  # The values are only accessible in the context of the passed block.
  # The values can be shadowed by calling `with_values` nested.
  def with_empty_values(**kwargs, &)
    previous = value_context
    new_metadata = Log::Metadata.empty.not_nil!.extend(kwargs) unless kwargs.empty?
    begin
      @value_context = new_metadata
      yield
    ensure
      @value_context = previous
    end
  end

  # fetch a context value using the passed symbol as key, if the key is not
  # known an `KeyError` will be raised.
  def [](key : Symbol) : Value
    fetch_value(key) { raise KeyError.new "Missing values key: #{key.inspect}" }
  end

  # fetch a context value using the passed symbol as key, if the
  # key is not known `nil` will be returned
  def []?(key : Symbol) : Log::Metadata::Value?
    fetch_value(key) { nil }
  end

  # fetch a context value using the passed symbol as key, if the key is not
  # known the context will be executed and its result will be returned
  def fetch_value(key, &block : {Symbol} ->)
    value_context.not_nil!.fetch(key, &block)
  end

  # iterates over all context values
  def each_value(&block : {Symbol, Log::Metadata::Value} ->)
    value_context.not_nil!.each(&block)
  end

  # inspects all values and returns them as a string
  def inspect_values : String
    io = IO::Memory.new
    value_context.not_nil!.to_s(io)
    io.to_s
  end

  # inspects all values and writes them to the given `io`
  def inspect_values(io : IO) : Nil
    value_context.not_nil!.to_s(io)
  end
end
