require 'nokogiri'

module RAWS
  module XML
    class Nokogiri
      def self.parse(doc, params={}, ret={})
        multiple = params[:multiple] || []
        unpack   = params[:unpack]   || []

        name = nil
        doc.children.each do |tag|
          name = tag.name

          unless ret[name].is_a? Array
            if ret.key?(name)
              ret[name] = [ret[name]]
            elsif multiple.include? name
              ret[name] = []
            end
          end

          if tag.child.is_a? ::Nokogiri::XML::Text
            if ret.key? name
              ret[name] << tag.content
            else
              ret[name] = tag.content
            end
          else
            if ret.key? name
              ret[name] << {}
              parse(tag, params, ret[name].last)
            else
              ret[name] = {}
              parse(tag, params, ret[name])
            end
          end
        end
        ret[name] = RAWS::XML.unpack_attrs(ret[name]) if unpack.include?(name)

        ret
      end

      def parse(xml, params={})
        self.class.parse(::Nokogiri::XML.parse(xml), params)
      end
    end
  end
end
