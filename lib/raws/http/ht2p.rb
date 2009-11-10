require 'ht2p'

class RAWS::HTTP::HT2P
  def fetch(http_verb, uri, header={}, body=nil, parser=nil, &block)
    RAWS.logger.debug([http_verb, uri, header, body, parser])

    begin
      body = body.to_s

      ::HT2P::Client.new(uri) do |request|
        request.method = http_verb.downcase.to_sym
        request.header.merge! header
        request.header['content-length'] = body.size.to_i
        response = request.send do |io|
          io.write body
        end

        RAWS.logger.debug(response)

        case response.code
        when 200...300
          block.call(RAWS::HTTP::HT2P::Response.new(response, parser))
        when 300...400
          raise RAWS::HTTP::Redirect.new(
            RAWS::HTTP::HT2P::Response.new(response)
          )
        else
          raise RAWS::HTTP::Error.new(
            RAWS::HTTP::HT2P::Response.new(response)
          )
        end
      end
    rescue RAWS::HTTP::Redirect => e
      r = e.response
      uri = r.header['location'] || r.doc['Error']['Endpoint']
      retry
    end
  end

  class Response < ::RAWS::HTTP::Response
    attr_reader :code
    attr_reader :header
    attr_reader :body

    def initialize(response, params={})
      @response = response
      @params   = params
      @code     = response.code
      @header   = response.header
      @body     = ''
      response.receive do |io|
        @body = io.read
      end
    end

    def doc
      @doc ||= RAWS.xml.parse(@body, @params) if @params
    end
  end
end
