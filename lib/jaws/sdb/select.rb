class JAWS::SDB::Select
  RESERVED_KEYWORD = %w'or and not from where select like null is order by asc desc in between intersection limit every'

  def initialize
    @output_list = '*'
    @domain      = nil
    @condition   = nil
    @values      = nil
    @sort        = nil
    @limit       = nil
  end

  def attr_filter(key, val)
    [key, val]
  end

  def columns(*val)
    @output_list = val.join(',')
    self
  end

  def from(val)
    @domain = val
    self
  end

  def where(condition, *values)
    @condition = condition
    @values    = values
    self
  end

  def order(val)
    @sort = val
    self
  end

  def limit(val)
    @limit = val
    self
  end

  def to_sql

    s = [
      'select',
      @output_list,
      'from',
      ::JAWS::SDB::Adapter.quote(@domain)
    ]

    s.push('where',    @condition) if @condition
    s.push('order by', @sort     ) if @sort
    s.push('limit',    @limit    ) if @limit

    [s.join(' '), @values]
  end

  def each(&block)
    JAWS::SDB.select(*to_sql, &block)
    #do |key, val|
    #  block.call(*attr_filter(key, val))
    #end
  end
end
