require 'helper'

class TestClient < Test::Unit::TestCase
  
  context "testing my client" do
    setup do 
      init_config
      @ft = GData::Client::Tables.new
      @ft.clientlogin(username, password)
    end
    
    should "assert true" do
      assert true
    end
  end
end
