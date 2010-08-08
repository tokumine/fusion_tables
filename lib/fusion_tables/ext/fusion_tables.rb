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
    class Tables < Base
      
      # Create a new table. Return the table id
      def create_table(sql)
          resp = self.sql_post(sql)
          table_id = resp.body.split("\n")[1].chomp.to_i
      end

      # Returns a hash with the definitions of all columns 
      def describe_table(table_id)
          resp = self.sql_get("DESCRIBE #{table_id}")
          
          columns = {}
          first = true
          CSV::Reader.parse(resp.body) do |row|
              if first
                  first = false
                  next
              end

              columns[row[1]] = { :id => row[0], :type => row[2] }
          end

          return columns
      end
    end
  end
end
