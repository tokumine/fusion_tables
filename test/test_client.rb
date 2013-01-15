require 'helper'

class TestClient < Test::Unit::TestCase
  
  context "The fusion_tables client library" do
    setup do 
      init_config
      @ft = GData::Client::FusionTables.new      
      @ft.clientlogin(username, password)
    end

    should "be properly setup" do      
      assert_equal "fusiontables", @ft.clientlogin_service
      assert_equal "application/x-www-form-urlencoded", @ft.headers["Content-Type"]
    end
    
    should "be able to authenticate with the google services" do
      assert_equal "fusiontables", @ft.auth_handler.service
      assert @ft.auth_handler.token
    end

    should "raise ArgumentError if no api key supplied" do
      @ft.set_api_key(nil)
      assert_raise ArgumentError do
        @ft.sql_get "SHOW TABLES" 
      end
    end
  end
end
