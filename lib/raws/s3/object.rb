class RAWS::S3::Object
  attr_reader :bucket, :name

  def initialize(bucket, name)
    @bucket, @name = bucket, name
  end

  def header
    @header ||= @bucket.head(@name).header
  end

  def metadata
    @metadata ||= Metadata.new(self)
  end

  def content
    @content ||= @bucket.get(@name).body
  end

  def save
    @bucket.put(@name, content, metadata.encode)
  end

  def delete
    @bucket.delete(@name)
  end

  class Metadata < Hash
    X_AMZ_META = 'x-amz-meta-'

    def initialize(object)
      super()
      @object = object
      decode(@object.header)
    end

    def [](key)
      super(X_AMZ_META + key)
    end

    def []=(key, val)
      super(X_AMZ_META + key, val)
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
        if val.is_a? Array
          ret[key] = val.map do |v|
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
