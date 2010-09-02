# Copyright (C) 2010 Simon Tokumine
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module GData
  module Client
    class FusionTables < Base
      class Table
        attr_reader :headers, :id, :name                      
        
        # configures headers hash and sets up
        #
        # eg options: {:table_id => "x", :name => "y"}
        #
        def initialize client, options
          raise ArgumentError, "need ft client" if client.class != GData::Client::FusionTables 
          raise ArgumentError, "need table_id and name hash" if !options.has_key?(:name) || !options.has_key?(:table_id) 
          @client = client
          @id = options[:table_id]
          @name = options[:name]
        end


        # Sets up data types from google
        #
        def describe
          GData::Client::FusionTables::Data.parse(@client.sql_get("DESCRIBE #{@id}")).body
        end
                
        # Runs select and returns data obj
        #
        # Define columns and SQL conditions separatly
        # 
        # See http://code.google.com/apis/fusiontables/docs/developers_reference.html#Select 
        #
        # use columns=ROWID to select row ids
        #
        def select columns="*", conditions=nil
          sql = "SELECT #{columns} FROM #{@id} #{conditions}"
          GData::Client::FusionTables::Data.parse(@client.sql_get(sql)).body
        end
        
        # Returns a count of rows. SQL conditions optional
        #
        def count conditions=nil
          select("count()", conditions).first.values.first.to_i
        end
        
        
        # Outputs data to an array of concatenated INSERT SQL statements
        #
        # format should be:
        #
        # [{:col_1 => data, :col2 => data}, {:col_1 => data, :col2 => data}]
        #
        # Fields are escaped and formatted for FT based on type
        #
        def insert data
          
          # encode values to insert
          data = encode data
          
          # Chunk up the data and send
          chunk = ""
          data.each_with_index do |d,i|            
            chunk << "INSERT INTO #{@id} (#{ d.keys.join(",") }) VALUES (#{ d.values.join(",") });"
            if (i+1) % 500 == 0 || (i+1) == data.size
              begin
                @client.sql_post(chunk)
                chunk = ""
              rescue => e
                raise "INSERT to table:#{@id} failed on row #{i} with #{e}"
              end  
            end  
          end
        end                

        # Runs update on rows and return data obj
        # No bulk update, so may aswell drop table and start again
        #
        # TODO: FIXME
        #
        #def update row_id, data          
        #  data = encode([data]).first
        #  data = data.to_a.map{|x| x.join("=")}.join(", ")
        #  
        #  sql = "UPDATE #{@id} SET #{data} WHERE ROWID = #{row_id}"
        #  GData::Client::FusionTables::Data.parse(@client.sql_post(sql)).body
        #end
        
        # delete row
        # no bulk delete so may aswell drop table and start again
        def delete row_id
          sql = "DELETE FROM #{@id} WHERE rowid='#{row_id}'"
          GData::Client::FusionTables::Data.parse(@client.sql_post(sql)).body
        end
        
        
        def get_headers
          @headers ||= describe
        end                  
        
        def encode data
          data.inject([]) do |ar,h|
            ret = {}
            h.each do |key, value|              
              ret["'#{key.to_s}'"] = case get_datatype(key)
                when "number"   then  "#{value}"
                when "datetime" then  "'#{value.strftime("%m-%d-%Y %H:%M:%S")}'"
                else                  "'#{value.gsub(/\\/, '\&\&').gsub(/'/, "''")}'"                            
              end
            end
            ar << ret
            ar      
          end
        end  
                
        # 
        # Returns datatype of given column name
        #
        def get_datatype column_name
          get_headers
          
          @headers.each do |h|
            return h[:type] if h[:name] == column_name.to_s
          end            
          raise ArgumentError "The column doesn't exist"
        end      
      end
    end
  end
end