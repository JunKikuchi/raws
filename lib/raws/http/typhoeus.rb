require 'typhoeus'

# Add head method.
module Typhoeus
  class Easy
    OPTION_VALUES[:CURLOPT_NOBODY] = 44

    def method=(method)
      @method = method
      if method == :get
        set_option(OPTION_VALUES[:CURLOPT_HTTPGET], 1)
      elsif method == :post
        set_option(OPTION_VALUES[:CURLOPT_HTTPPOST], 1)
        self.post_data = ""
      elsif method == :put
        set_option(OPTION_VALUES[:CURLOPT_UPLOAD], 1)
        self.request_body = "" unless @request_body
      elsif method == :head
        set_option(OPTION_VALUES[:CURLOPT_NOBODY], 1)
      else
        set_option(OPTION_VALUES[:CURLOPT_CUSTOMREQUEST], "DELETE")
      end
    end
  end

  module ClassMethods
    [:get, :post, :put, :delete, :head].each do |method|
      line = __LINE__ + 2  # get any errors on the correct line num
      code = <<-SRC
        def #{method.to_s}(url, options = {})
          mock_object = get_mock(:#{method.to_s}, url, options)
          unless mock_object.nil?
            decode_nil_response(mock_object)
          else
            enforce_allow_net_connect!(:#{method.to_s}, url, options[:params])
            remote_proxy_object(url, :#{method.to_s}, options)
          end
        end
      SRC
      module_eval(code, "./lib/typhoeus/remote.rb", line)
    end
  end
end

class RAWS::HTTP::Typhoeus
  def fetch(http_verb, uri, header={}, body=nil, parser=nil, &block)
    RAWS.logger.debug([http_verb, uri, header, body, parser])

    begin
      response = ::Typhoeus::Request.__send__(
        http_verb.downcase.to_sym,
        uri,
        {
          :headers => header,
          :body    => body
        }
      )

      RAWS.logger.debug(response)

      case response.code
      when 200...300
        block.call(Response.new(response, parser))
      when 300...400
        raise Redirect.new(Response.new(response))
      else
        raise Error.new(Response.new(response))
      end
    rescue Redirect => e
      r = e.response
      uri = r.header['location'] || r.doc['Error']['Endpoint']
      retry
    end
  end

  class Response < ::RAWS::HTTP::Response
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
