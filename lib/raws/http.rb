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

    autoload :Typhoeus, 'raws/http/typhoeus'
  end
end
