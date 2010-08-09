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
        def describe
          GData::Client::FusionTables::Data.parse(@client.sql_get("DESCRIBE #{@id}")).body
        end
        
        def get_headers
          @headers ||= describe
        end            
        
        def get_headers_for_insert
          @headers ||= describe
          @headers.map { |x| x.delete_if { |key,value| key == :column_id } }
        end                    

        # Runs select and returns data obj
        def select
          get_headers
        end
        
        # Outputs data to an array of concatenated INSERT SQL statements
        def insert
          get_headers
        end            

        # Runs update and returns data obj
        def update
          get_headers
        end
        
        # deletes table
        def delete
          get_headers
        end
      end
    end
  end
end