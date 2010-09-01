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
      class Data
        include Enumerable
        
        attr_reader :headers, :body, :live
        alias :to_h :body  
        
        # configures headers hash and sets up
        def initialize options
          @headers = options[:headers]
          @body = options[:body]          
        end
        
        # Reads in CSV
        def self.parse response
          body = []
          headers = []
          
          first = true
          if CSV.const_defined? :Reader
            CSV::Reader.parse(response.body) do |row|
              if first
                first = false
                headers = row.map { |x|x.strip.downcase.gsub(" ","_").to_sym }
                next
              end
              body << Hash[*headers.zip(row).flatten]
            end
          else
            CSV.parse(response.body) do |row|
              if first
                first = false
                headers = row.map { |x|x.strip.downcase.gsub(" ","_").to_sym }
                next
              end
              body << Hash[*headers.zip(row).flatten]
            end              
          end              
          self.new :headers => headers, :body => body
        end
                            
        # Implement enumerable                
        def each
          @body.each { |i| yield i }
        end                
                                
        private
        # Encodes row according to type
        def encode
          
        end
        
      end
    end
  end
end