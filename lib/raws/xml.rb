module RAWS
  module XML
    def self.unpack_attrs(attrs)
      ret = {}

      if attrs.is_a? Array
        attrs
      else
        [attrs]
      end.map do |val|
        name, value = val['Name'], val['Value']

        if ret.key? name
          ret[name] = [ret[name]] unless ret[name].is_a? Array
          ret[name] << value
        else
          ret[name] = value
        end
      end if attrs

      ret
    end

    autoload :Nokogiri, 'raws/xml/nokogiri'
  end
end
