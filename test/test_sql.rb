require 'helper'

class TestTable < Test::Unit::TestCase
  
  context "testing plain SQL" do
    setup do 
      init_config
      @ft = GData::Client::FusionTables.new      
      @ft.clientlogin(username, password)
      @ft.set_api_key(api_key)
      @table = @ft.create_table "test", [{:name  => 'firstname',  :type => 'string'},
                                         {:name  => 'phone',      :type => 'number'},
                                         {:name  => 'dob',        :type => 'datetime'},
                                         {:name  => 'house',      :type => 'location'}]
    end

    teardown do
      @ft.drop(@table.id)
    end
    
    should "be able to SHOW TABLES" do
      ret = @ft.execute "SHOW TABLES"      
      assert !ret.empty?
      assert_equal Array, ret.class
    end  
    
    should "be able to DESCRIBE a table" do
      ret = @ft.execute("DESCRIBE #{@table.id}")      
      expected = [{:column_id=>"col0", :name=>"firstname", :type=>"string"},
                  {:column_id=>"col1", :name=>"phone", :type=>"number"},
                  {:column_id=>"col2", :name=>"dob", :type=>"datetime"},
                  {:column_id=>"col3", :name=>"house", :type=>"location"}]
      assert_equal expected, ret                 
    end
    
    should "be able to INSERT a row" do
      ret = @ft.execute "INSERT INTO #{@table.id} (firstname) VALUES ('eric');"
      assert_equal 1, ret.first[:rowid].to_i
    end  
    
    should "be able to SELECT a row" do
      @ft.execute "INSERT INTO #{@table.id} (firstname) VALUES ('eric');"      
      ret = @ft.execute "SELECT ROWID, firstname FROM #{@table.id}"
      assert_equal [{:rowid=>"1", :firstname=>"eric"}], ret
    end  
    
    should "be able to UPDATE a row" do
      @ft.execute "INSERT INTO #{@table.id} (firstname) VALUES ('eric');"      
      
      ret = @ft.execute "SELECT ROWID, firstname FROM #{@table.id}"
      assert_equal [{:rowid=>"1", :firstname=>"eric"}], ret
      
      ret = @ft.execute "UPDATE #{@table.id} SET firstname='simon' WHERE ROWID = '#{ret.first[:rowid]}'"
      ret = @ft.execute "SELECT ROWID, firstname FROM #{@table.id}"
      assert_equal [{:rowid=>"1", :firstname=>"simon"}], ret      
    end
    
    should "be able to DELETE a row" do
      @ft.execute "INSERT INTO #{@table.id} (firstname) VALUES ('eric');"
      @ft.execute "INSERT INTO #{@table.id} (firstname) VALUES ('eric');"
            
      ret = @ft.execute "SELECT ROWID FROM #{@table.id};"      
      @ft.execute "DELETE FROM #{@table.id} WHERE ROWID = '#{ret.first[:rowid]}';"      
      
      ret = @ft.execute "SELECT count() FROM #{@table.id};"
      
      assert_equal 1, ret.first[:"count()"].to_i  
    end    
    
    # should "be able to query geographic data" do
    #   @table = @ft.create_table "test", [{:name  => 'name',      :type => 'string'},
    #                                      {:name  => 'geo',       :type => 'location'}]
          
    #   @ft.execute "INSERT INTO #{@table.id} (name, geo) VALUES ('tokyo',   '35.6894 139.6917');
    #                INSERT INTO #{@table.id} (name, geo) VALUES ('osaka',   '34.6937 135.5021');
    #                INSERT INTO #{@table.id} (name, geo) VALUES ('fukuoka', '33.5903 130.4017');
    #                INSERT INTO #{@table.id} (name, geo) VALUES ('kyoto',   '35.0116 135.7680');
    #                INSERT INTO #{@table.id} (name, geo) VALUES ('nagoya',  '35.1814 136.9063');"
      
    #   # get cities nearest to Nara
    #   res = @ft.execute "SELECT * FROM #{@table.id} ORDER BY ST_DISTANCE(geo, LATLNG(35.6894,139.6917)) LIMIT 10"
    #   puts res.inspect
    # end 
  end  
end    