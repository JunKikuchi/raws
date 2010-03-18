module RAWS
  module XML
    def self.unpack_attrs(attrs)
      [attrs].flatten.inject({}) do |ret, val|
        name, value = val['Name'], val['Value']

        name && value && if ret.key? name
          ret[name] = [ret[name]] unless ret[name].is_a? Array
          ret[name] << value
        else
          ret[name] = value
        end

        ret
      end
    end

    autoload :Nokogiri, 'raws/xml/nokogiri'
  end
end
