require 'ht2p'

module RAWS::HTTP::HT2P
  def self.connect(uri, &block)
    response = nil
    begin
      HT2P::Client.new uri do |request|
        response = block.call(Request.new(request))
      end
    rescue RAWS::HTTP::Redirect => e
      r = e.response
      uri = r.header['location'] || r.doc['Error']['Endpoint']
      retry
    end
    response
  end

  class Request < RAWS::HTTP::Request
    def initialize(request)
      @request, @before_send = request, nil
    end

    def method
      @request.method
    end

    def method=(val)
      @request.method = val
    end

    def header
      @request.header
    end

    def before_send(&block)
      @before_send = block
    end

    def send(body=nil, &block)
      RAWS.logger.debug self
      @before_send && @before_send.call(self)
      response = Response.new(@request.send(body, &block))
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
    end

    def code
      @response.code
    end

    def header
      @response.header
    end

    def receive(&block)
      if block_given?
        @response.receive(&block)
      else
        @body = @response.receive
      end
    end

    def parse(params={})
      @doc = RAWS.xml.parse(receive, params)
    end
  end
end
