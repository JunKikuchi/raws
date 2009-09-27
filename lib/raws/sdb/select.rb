class RAWS::SDB::Select
  RESERVED_KEYWORD = %w'or and not from where select like null is order by asc desc in between intersection limit every'

  def initialize
    @output_list = '*'
    @domain      = nil
    @condition   = nil
    @values      = nil
    @sort        = nil
    @limit       = nil
  end

  def fetch(&block)
    RAWS::SDB.select(*to_sql) do |val|
      block.call(attr_filter(val))
    end
  end

  def attr_filter(val)
    val
  end

  def columns(*val, &block)
    @output_list = val.join(',')
    fetch(&block) if block_given?
    self
  end

  def from(val, &block)
    @domain = val
    fetch(&block) if block_given?
    self
  end

  def where(condition, *values, &block)
    @condition = condition
    @values    = values
    fetch(&block) if block_given?
    self
  end

  def order(val, &block)
    @sort = val
    fetch(&block) if block_given?
    self
  end

  def limit(val, &block)
    @limit = val
    fetch(&block) if block_given?
    self
  end

  def to_sql
    s = [
      'select',
      @output_list,
      'from',
      ::RAWS::SDB::Adapter.quote(@domain)
    ]

    s.push('where',    @condition) if @condition
    s.push('order by', @sort     ) if @sort
    s.push('limit',    @limit    ) if @limit

    [s.join(' '), @values]
  end
end
