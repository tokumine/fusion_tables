require 'helper'

class TestExt < Test::Unit::TestCase
 
  context "The Fusion Tables helper functions" do
    setup do 
      init_config
      @ft = GData::Client::FusionTables.new      
      @ft.clientlogin(username, password)
    end
  
    
    should "raise ArgumentError if supply unknown types to it" do
      assert_raise ArgumentError do
        @ft.create_table "test table", [{:name => "test_col", :type => "billys birthday" }]
      end
    end  
  
    should "let you create a table if you get everything right" do
      table = @ft.create_table "test_table", [{:name => "test_col", :type => "string" }]
      assert_equal table.class, GData::Client::FusionTables::Table
      @ft.drop(table.id)
    end

    should "correct your table name to a certain degree on create" do
      table = @ft.create_table "test table", [{:name => "test col", :type => "string" }]
      assert_equal table.name, "test_table"
      @ft.drop(table.id)
    end

    should "return you a list of your fusion tables" do
      resp = @ft.show_tables
      assert_equal resp.first.class, GData::Client::FusionTables::Table if resp.first       
    end
    
    should "be possible to delete a table with an id" do
      table = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      assert_equal @ft.drop(table.id), 1
    end

    should "be possible to delete tables with an array of ids" do
      table1 = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      table2 = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      assert_equal @ft.drop([table1.id, table2.id]), 2
    end
 
    should "be possible to delete multiple tables with a regex" do
      table1 = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      table2 = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      assert_equal @ft.drop(/^test_/), 2      
    end
   
    should "return zero if passed a silly id" do
      assert_equal @ft.drop(235243875629384756), 0      
    end    
  end

end
