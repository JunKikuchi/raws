module RAWS
  module HTTP
    class Redirect < Exception
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end

    class Error < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end

    class Request; end
    class Response; end

    autoload :Typhoeus, 'raws/http/typhoeus'
    autoload :HT2P, 'raws/http/ht2p'
  end
end
