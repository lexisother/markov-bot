require 'pg'
require 'thread'

module Scrap
  class Database
    RECONN_MAX = 3

    def initialize(config = {})
      @pg = PG::Connection.open(**config)
      @mutex = Mutex.new

      @pg.type_map_for_queries = PG::BasicTypeMapForQueries.new(@pg)
      @pg.type_map_for_results = PG::BasicTypeMapForResults.new(@pg)
    end

    def query(sql, args = [], &blk)
      @mutex.synchronize do
        reconn = 0

        begin
          @pg.exec_params(sql, args, &blk)
        rescue PG::UnableToSend
          raise if reconn > RECONN_MAX

          puts "FAILED TO CONNECT TO DB!!! Retrying..."
          
          @pg.reset
          reconn += 1
          retry
        end
      end
    end

    def transaction
      @mutex.synchronize { @pg.transaction { yield self } }
    end

    def disconnecting
      @pg.close
    end
  end
end