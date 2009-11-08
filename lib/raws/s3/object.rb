class RAWS::S3::Object
  def header
  end

  def metadata
  end

  def read(length=nil)
  end

  def write(val)
  end

  class Metadata < Hash
    X_AMZ_META = 'x-amz-meta-'

    def initialize(object)
      super()
      @object = object
      decode(@object.header)
    end

    def decode(header)
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
    end

    def encode
      self.inject({}) do |ret, (key, val)|
        key = X_AMZ_META + key

        if val.is_a? Array
          ret[ key] = val.map do |v|
            RAWS.escape(v.strip)
          end.join(',')
        else
          ret[key] = RAWS.escape(val.strip)
        end

        ret
      end
    end
  end
end
