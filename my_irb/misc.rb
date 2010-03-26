module MyIrb::Misc
  def q
    exit
  end

  # Profiles passed block
  def profile(min_percent)
    require "ruby-prof"
    RubyProf.measure_mode = RubyProf::CPU_TIME

    begin
      RubyProf.start
      yield
    ensure
      results = RubyProf.stop
    end

    printer = RubyProf::FlatPrinter.new(results)

    string_io = StringIO.new
    printer.print(string_io, :min_percent => min_percent)
    puts string_io.string
    nil
  end

  # Returns current process memory usage
  def memory_usage
    `ps -o rss= -p #{ $PID }`.to_i
  end

  # Returns delta of memory_usage after yielding to block
  def memory_growth
    memory_begin = memory_usage
    begin
      yield
    ensure
      memory_end = memory_usage
    end
    memory_end - memory_begin
  end
end