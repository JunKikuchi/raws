require 'typhoeus'
require 'stringio'

class RAWS::HTTP::Typhoeus
  def self.connect(uri, &block)
    response = nil
    begin
      response = block.call(Request.new(uri))
    rescue RAWS::HTTP::Redirect => e
      r = e.response
      uri = r.header['location'] || r.doc['Error']['Endpoint']
      retry
    end
    response
  end

  class Request < RAWS::HTTP::Request
    attr_reader :header
    attr_accessor :uri, :method

    def initialize(uri)
      @uri, @header, @method, @before_send = uri, {}, :get , nil
    end

    def before_send(&block)
      @before_send = block
    end

    def send(body=nil, &block)
      RAWS.logger.debug self
      @before_send && @before_send.call(self)
      response = Response.new(
        ::Typhoeus::Request.__send__(
          @method.downcase.to_sym,
          @uri,
          :headers => @header,
          :body => if block_given?
            # TODO エラーにした方が。。。　
            io = StringIO.new
            block.call(io)
            if io.size > 0
              io.rewind
              io.read
            end
          else
            body
          end
        )
      )
      case response.code
      when 200...300
        response
      when 300...400
        response.parse
        raise RAWS::HTTP::Redirect.new(response)
      else
        response.parse
        raise RAWS::HTTP::Error.new(response)
      end
    end
  end

  class Response < RAWS::HTTP::Response
    attr_reader :body, :doc

    def initialize(response)
      @response, @body, @doc = response, nil, nil
      @header = @response.headers.split("\r\n").inject({}) do |ret, val|
        if md = /(.+?):\s*(.*)/.match(val)
          ret[md[1].downcase] = md[2]
        end
        ret
      end
    end

    def code
      @response.code
    end

    def receive(&block)
      if block_given?
        block.call(StringIO.new(@response.body)) # TODO エラーにした方が。。。
      else
        @body = @response.body
      end
    end

    def parse(params={})
      @doc = RAWS.xml.parse(receive, params)
    end
  end
end
