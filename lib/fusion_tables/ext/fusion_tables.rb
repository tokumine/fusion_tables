# Copyright (C) 2010 Tom Verbeure, Simon Tokumine
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
                          
      # Show a list of fusion tables
      def show_tables 
        data = GData::Client::FusionTables::Data.parse(self.sql_get("SHOW TABLES"))
        data.inject([]) do |x, row|
          x << GData::Client::FusionTables::Table.new(self, row)        
          x
        end  
      end

            
      # Create a new table. Return the corresponding table
      # 
      # Columns specified as [{:name => 'my_col_name', :type => 'my_type'}]
      #
      # Type must be one of:
      # 
      # * number 
      # * string 
      # * location
      # * datetime
      #
      def create_table(table_name, columns)
        
        # Sanity check name
        table_name = table_name.strip.gsub(/ /,'_')
        
        # ensure all column types are valid
        columns.each do |col|
          if !DATATYPES.include? col[:type].downcase
            raise ArgumentError, "Ensure input types are: 'number', 'string', 'location' or 'datetime'"
          end  
        end
        
        # generate sql
        fields = columns.map{ |col| "'#{col[:name]}': #{col[:type].upcase}" }.join(", ")
        sql = "CREATE TABLE #{table_name} (#{fields})"
        
        # create table        
        resp = self.sql_post(sql)
        raise "unknown column type" if resp.body == "Unknown column type."
        
        # construct table object and return        
        table_id = resp.body.split("\n")[1].chomp.to_i
        table = GData::Client::FusionTables::Table.new(self, :table_id => table_id, :name => table_name)
        table.get_headers
        table
      end
      
      # Drops Fusion Tables
      #
      # options can be:
      #
      # * an integer for single drop 
      # * array of integers for multi drop
      # * a regex against table_name for flexible multi_drop 
      #
      def drop(options)
        # collect ids
        ids = []
        ids << options  if options.class == Integer || options.class == String || Fixnum
        ids =  options  if options.class == Array
        
        if options.class == Regexp
          tables = show_tables
          ids = tables.map { |table| table.id if options =~ table.name }.compact
        end       
        
        # drop tables  
        delete_count = 0
        ids.each do |id|  
          resp = self.sql_post("DROP TABLE #{id}") 
          delete_count += 1 if resp.body.strip.downcase == 'ok'          
        end
        delete_count      
      end        
    end
  end
end
