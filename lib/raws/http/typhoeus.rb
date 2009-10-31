require 'typhoeus'

module RAWS
  module HTTP
    class Typhoeus
      include ::Typhoeus

      def fetch(http_verb, uri, header={}, body=nil, parser=nil)
        begin
          response = self.class.__send__(
            http_verb.downcase.to_sym,
            uri,
            {
              :headers => header,
              :body    => body
            }
          )
          case response.code
          when 200...300
            Response.new(response, parser)
          when 300...400
            raise Redirect.new(Response.new(response))
          else
            raise Error.new(Response.new(response))
          end
        rescue Redirect => e
          p uri = e.response.header['location']
          retry
        end
      end

      class Response
        attr_reader :code
        attr_reader :body

        def initialize(response, params={})
          @response = response
          @params   = params
          @code     = response.code
          @body     = response.body
        end

        def header
          @header ||= @response.headers.split("\r\n").inject({}) do |ret, val|
            if md = /(.+?):\s*(.*)/.match(val)
              ret[md[1].downcase] = md[2]
            end
            ret
          end
        end

        def doc
          @doc ||= RAWS.xml.parse(@body, @params) if @params
        end
      end
    end
  end
end
