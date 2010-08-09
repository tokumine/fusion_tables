require 'helper'

class TestClient < Test::Unit::TestCase
  
  context "The fusion_tables client library" do
    setup do 
      init_config
      @ft = GData::Client::FusionTables.new      
      @ft.clientlogin(username, password)
    end

    should "be properly setup" do      
      assert_equal @ft.clientlogin_service, "fusiontables"      
      assert_equal @ft.headers["Content-Type"], "application/x-www-form-urlencoded"
    end
    
    should "be able to authenticate with the google services" do
      assert_equal @ft.auth_handler.service, "fusiontables"
      assert @ft.auth_handler.token
    end
  end
end
