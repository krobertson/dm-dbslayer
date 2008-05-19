require 'net/http'
require 'json/pure'

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
        query = query_url(args)        
        response = Net::HTTP.get_response(query.host, "#{query.path}?#{query.query}", query.port)

        if response.is_a?(Net::HTTPSuccess)
          dbresponse = JSON.parse(response.body)
          
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

        else
          raise DbslayerWebException, "Web error #{response.class}: #{response.body}"
        end
      end

      def query_url(args)
        sql = args.size > 0 ? escape_sql(args) : @text
        query = URI.encode({ 'SQL' => sql }.to_json)
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