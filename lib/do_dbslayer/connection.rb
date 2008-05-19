module DataObjects
  module Dbslayer
    class Connection < DataObjects::Connection
      attr_reader :uri

      def initialize(uri)
        @uri = uri.is_a?(String) ? Addressable::URI.parse(uri) : uri
      end
      
      def real_close
      end
      
      def db_url
        "http://#{uri.host}#{port}/db"
      end
      
      def port
        uri.port.nil? ? ':9090' : ":#{uri.port}"
      end
    end
  end
end