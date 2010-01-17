class RAWS::S3::Metadata < Hash
  X_AMZ_META = 'x-amz-meta-'

  def initialize(header)
    super()
    @header = header
    decode(header)
  end

  def reload
    @header.reload
    decode(@header)
  end

  def decode(header)
    clear
    header.select do |key, val|
      key.match(/^#{X_AMZ_META}/)
    end.each do |key, val|
      self[key.sub(X_AMZ_META, '')] = begin
        a = val.split(',').map do |val|
          RAWS.unescape(val)
        end
        1 < a.size ? a : a.first
      end
    end
    self
  end

  def encode
    self.inject({}) do |ret, (key, val)|
      key = X_AMZ_META + key

      if val.is_a? Array
        ret[key] = val.map do |v|
          RAWS.escape v
        end.join(',')
      else
        ret[key] = RAWS.escape val
      end

      ret
    end
  end
end
