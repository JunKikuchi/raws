class RAWS::SDB::Select
  include Enumerable

  RESERVED_KEYWORD = %w'or and not from where select like null is order by asc desc in between intersection limit every'

  def initialize
    @output_list = '*'
    @domain      = nil
    @condition   = nil
    @values      = nil
    @sort        = nil
    @limit       = nil
  end

  def attr_filter(val)
    val
  end

  def each(&block)
    RAWS::SDB.select(*to_sql) do |val|
      block.call(attr_filter(val))
    end
  end
  alias :fetch :each

  def get
    ret = nil

    _limit = @limit
    limit(1)
    each do |val|
      ret = val
    end
    @limit = _limit

    ret
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
  alias :filter :where

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
      "`#{::RAWS::SDB::Adapter.quote(@domain)}`"
    ]

    s.push('where',    @condition) if @condition
    s.push('order by', @sort     ) if @sort
    s.push('limit',    @limit    ) if @limit

    [s.join(' '), @values]
  end
end
