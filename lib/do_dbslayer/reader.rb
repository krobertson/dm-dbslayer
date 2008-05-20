module DataObjects
  module Dbslayer
    class Reader
      def initialize(results)
        @results = results
        @position = 0
      end

      def fields
        @results['HEADER']
      end

      def values
        @current_row
      end

      def close
      end

      def next!
        return false if(@position >= @results['ROWS'].size)

        @current_row = convert(@results['ROWS'][@position])
        @position = @position + 1
        true
      end

      private

      def convert(row)
        results = []
        row.each_index do |p|
          col = case @results['TYPES'][p]
          when 'MYSQL_TYPE_NEWDECIMAL'
            BigDecimal.new(row[p])
          when 'MYSQL_TYPE_BIT'
            row[p] == '1'
          when 'MYSQL_TYPE_DATE'
            Date.strptime(row[p], '%Y-%m-%d')
          when 'MYSQL_TYPE_TIME'
            Time.parse(row[p])
          when 'MYSQL_TYPE_TIMESTAMP'
            Time.parse(row[p])
          when 'MYSQL_TYPE_DATETIME'
            DateTime.strptime(row[p], '%Y-%m-%d %H:%M:%S')
          when 'MYSQL_TYPE_YEAR'
            row[p].to_i
          when 'MYSQL_TYPE_BLOB'
            row[p]
          when 'MYSQL_TYPE_TINY_BLOB'
            row[p]
          when 'MYSQL_TYPE_MEDIUM_BLOB'
            row[p]
          when 'MYSQL_TYPE_LONG_BLOB'
            row[p]
          when 'MYSQL_TYPE_TINY'
            row[p] == 1   # Bool
          when 'MYSQL_TYPE_NULL'
            nil
          else row[p]
          end

          # Following not needed since already the right type
          #when 'MYSQL_TYPE_SHORT'       : row[p].to_i
          #when 'MYSQL_TYPE_LONG'        : row[p].to_i
          #when 'MYSQL_TYPE_INT24'       : row[p].to_i
          #when 'MYSQL_TYPE_DECIMAL'     : row[p].to_f
          #when 'MYSQL_TYPE_DOUBLE'      : row[p].to_f
          #when 'MYSQL_TYPE_FLOAT'       : row[p].to_f
          #when 'MYSQL_TYPE_LONGLONG'    : row[p].to_f
          #when 'MYSQL_TYPE_STRING'      : row[p]
          #when 'MYSQL_TYPE_VAR_STRING'  : row[p]
          #when 'MYSQL_TYPE_NEWDATE'     : row[p]
          #when 'MYSQL_TYPE_VARCHAR'     : row[p]
          ##when 'MYSQL_TYPE_SET'         : nil
          ##when 'MYSQL_TYPE_ENUM'        : row[p]
          ##when 'MYSQL_TYPE_GEOMETRY'    : nil
          results << col
        end
        results
      end
    end
  end
end