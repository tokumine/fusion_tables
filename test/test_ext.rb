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
      assert_equal GData::Client::FusionTables::Table, table.class
      @ft.drop(table.id)
    end

    should "correct your table name to a certain degree on create" do
      table = @ft.create_table "test table", [{:name => "test col", :type => "string" }]
      assert_equal "test_table", table.name
      @ft.drop(table.id)
    end

    should "return you a list of your fusion tables" do
      resp = @ft.show_tables
      assert_equal GData::Client::FusionTables::Table, resp.first.class if resp.first
    end
    
    should "be possible to delete a table with an id" do
      table = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      assert_equal 1, @ft.drop(table.id)
    end

    should "be possible to delete tables with an array of ids" do
      table1 = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      table2 = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      assert_equal 2, @ft.drop([table1.id, table2.id])
    end
 
    should "be possible to delete multiple tables with a regex" do
      table1 = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      table2 = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      assert_equal 2, @ft.drop(/^test_/)
    end
   
    should "return zero if passed a silly id" do
      assert_equal 0, @ft.drop(235243875629384756)
    end    
  end

end
