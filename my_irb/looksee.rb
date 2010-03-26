module MyIrb::Looksee
  #
  # Alias for Looksee.lookup_path.
  #
  # (Added by Looksee.)
  #
  def lp(*args)
    MyIrb.gem("looksee") { Looksee.lookup_path(*args) }
  end

  #
  # Run Looksee.lookup_path on an instance of the given class.
  #
  # (Added by Looksee.)
  #
  def lpi(klass, *args)
    MyIrb.gem("looksee") { Looksee.lookup_path(klass.allocate, *args) }
  end
end