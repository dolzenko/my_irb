module MyIrb::ShellLike
  # Analogous to the +time+ console tool
  def time
    start = Time::now
    stimes = Process::times
    rval = yield
    etimes = Process::times
    $stderr.puts "Time elapsed: %0.5f user, %0.5f system (%0.5f wall clock seconds)" % [
            etimes.utime - stimes.utime,
            etimes.stime - stimes.stime,
            Time::now.to_f - start.to_f,
    ]
    rval
  end
end