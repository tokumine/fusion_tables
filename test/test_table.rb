require 'helper'

class TestTable < Test::Unit::TestCase
  
  context "uploading data to FT" do
    setup do 
      init_config
      @ft = GData::Client::FusionTables.new      
      @ft.clientlogin(username, password)
      @table = @ft.create_table "test", [{:name  => 'firstname',  :type => 'string'},
                                         {:name  => 'phone',      :type => 'number'},
                                         {:name  => 'dob',        :type => 'datetime'},
                                         {:name  => 'house',      :type => 'location'}]
    end

    teardown do
      @ft.drop(@table.id)
    end
   
    should "format data and prep for upload" do
      data = @table.encode [{:firstname => "\\bob's piz\za", 
                             :phone => 12, 
                             :dob => Time.utc(2010,"aug",10,20,15,1), 
                             :house => "POINT(1,1)"}]
      row = data.first
      assert_equal "'\\\\bob''s pizza'",      row["'firstname'"]
      assert_equal "#{12}",                   row["'phone'"] 
      assert_equal "'08-10-2010 20:15:01'",   row["'dob'"]
      assert_equal "'POINT(1,1)'",            row["'house'"]
    end
    
    should "be able to insert 1 row of data" do
      data = 1.times.inject([]) { |a,i|
               a << {:firstname => "\\bob's piz\za-#{i}", 
                     :phone => 12, 
                     :dob => Time.utc(2010,"aug",10,20,15,1), 
                     :house => '<Point><coordinates>-74.006393,40.714172,0</coordinates></Point>'}
             }
    
      @table.insert data       
    end
        
    should "be able to insert 501 rows of data" do
      data = 501.times.inject([]) { |a,i|
               a << {:firstname => "Person-#{i}", 
                     :phone => 12, 
                     :dob => Time.utc(2010,"aug",10,20,15,1), 
                     :house => "<Point><coordinates>#{180-rand(360)},#{90-rand(180)},0</coordinates></Point>"}
             }
      
      @table.insert data       
    end    
    
    
    should "be able to count the number of rows" do
       data = 2.times.inject([]) { |a,i|
                 a << {:firstname => "Person-#{i}", 
                       :phone => 12, 
                       :dob => Time.utc(2010,"aug",10,20,15,1), 
                       :house => "<Point><coordinates>#{180-rand(360)},#{90-rand(180)},0</coordinates></Point>"}
               }
    
        @table.insert data
        assert_equal 2, @table.count
    end
    
    should "be able to select the rows" do
       data = 2.times.inject([]) { |a,i|
                 a << {:firstname => "Person-#{i}", 
                       :phone => 12, 
                       :dob => Time.utc(2010,"aug",10,20,15,1), 
                       :house => "<Point><coordinates>1,1,0</coordinates></Point>"}
               }
    
        @table.insert data
        assert_equal [{:firstname=>"Person-0", :phone=>"12", :dob=>"08-10-2010 20:15:01", :house=>"<Point><coordinates>1,1,0</coordinates></Point>"}, {:firstname=>"Person-1", :phone=>"12", :dob=>"08-10-2010 20:15:01", :house=>"<Point><coordinates>1,1,0</coordinates></Point>"}], @table.select
    end
        
    should "be able to truncate all rows and start again" do
       data = 2.times.inject([]) { |a,i|
                 a << {:firstname => "Person-#{i}", 
                       :phone => 12, 
                       :dob => Time.utc(2010,"aug",10,20,15,1), 
                       :house => "<Point><coordinates>#{180-rand(360)},#{90-rand(180)},0</coordinates></Point>"}
               }
    
        @table.insert data
        assert_equal 2, @table.count
        @table.truncate!
        assert_equal 0, @table.count
        @table.insert data        
        assert_equal 2, @table.count
    end    
  end
end