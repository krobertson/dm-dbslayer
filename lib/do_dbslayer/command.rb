require 'uri'

module DataObjects
  module Dbslayer

    class DbslayerException < RuntimeError
    end

    class DbslayerWebException < RuntimeError
    end

    class Command < DataObjects::Command
      include DataObjects::Quoting
      
      def execute_non_query(*args)
        result = execute(args)

        if result['SUCCESS'] == true
          DataObjects::Result.new(self, result['AFFECTED_ROWS'].to_i, result['INSERT_ID'].to_i)
        else
          nil
        end
      end

      def execute_reader(*args)
        result = execute(args)
        Reader.new(result)
      end

      def execute(args)
        uri = ::URI.parse(query_url(args).to_s)
        dbresponse = Yajl::HttpStream.get(uri)
        
        if dbresponse['MYSQL_ERROR']
          raise DbslayerException, "MySQL Error #{dbresponse['MYSQL_ERRNO']}: #{dbresponse['MYSQL_ERROR']}"
        elsif dbresponse['RESULT']
          result = dbresponse['RESULT']
          case result
          when Hash
            return result
          when Array
            result.map { |r| return r }
          else  
            raise DbslayerException, "Unknown format for SQL results from DBSlayer"
          end
        elsif dbresponse['SUCCESS']
          return dbresponse['SUCCESS']
        else
          raise DbslayerException, "Unknown response type from DBSlayer"
        end
      rescue Yajl::ParseError => e
        raise Yajl::ParseError, "JSON parsing error #{e.class}: #{e.message}"
      rescue Exception => e
        raise DbslayerWebException, "Web error #{e.class}: #{e.message}"
      end

      def query_url(args)
        sql = args.size > 0 ? escape_sql(args) : @text
        query = ::URI.encode(Yajl::Encoder.encode({ 'SQL' => sql }))
        Addressable::URI.parse("#{@connection.db_url}?#{query}")
      end

      def set_types(column_types)
        @field_types = column_types.collect { |t| t.to_s }
      end

      def quote_date(value)
        "'#{value.strftime('%Y-%m-%d')}'"
      end

      def quote_time(value)
        "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'"
      end

      def quote_datetime(value)
        "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'"
      end
    end
  end
end