module MyIrb::Inflections
  def constantize(s)
    MyIrb::ActiveSupport::Inflector.constantize(s)
  end

  def camelize(s)
    MyIrb::ActiveSupport::Inflector.camelize(s)
  end

  def underscore(s)
    MyIrb::ActiveSupport::Inflector.underscore(s)
  end
end