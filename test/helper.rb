require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'yaml'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'fusion_tables'

class Test::Unit::TestCase
    
  def init_config
    if not defined? @config_file
      begin
        @config_file = YAML::load_file(File.join(File.dirname(__FILE__), 'test_config.yml'))
      rescue
        puts "Please configure your test_config.yml file using test_config.yml.sample as base"
      end    
    end
    @config_file
  end

  def username
    @config_file['username']
  end

  def password
    @config_file['password']
  end
  
  def table_name
    @config_file['table_name']
  end  
end
