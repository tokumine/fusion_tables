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
  end
end
