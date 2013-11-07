require 'helper'

class TestExt < Test::Unit::TestCase

  context "The Fusion Tables helper functions" do
    setup do
      init_config
      @ft = GData::Client::FusionTables.new
      @ft.clientlogin(username, password)
      @ft.set_api_key(api_key)
    end

    teardown do
      @ft.drop(@table.id) if @table and @table.id
    end

    should "raise ArgumentError if supply unknown types to it" do
      assert_raise ArgumentError do
        @ft.create_table "test table", [{:name => "test_col", :type => "billys birthday" }]
      end
    end

    should "let you create a table if you get everything right" do
      @table = @ft.create_table "test_table", [{:name => "test_col", :type => "string" }]
      assert_equal GData::Client::FusionTables::Table, @table.class
      assert @table.id.is_a? String
    end

    should "accept symbol for name and type" do
      @table = @ft.create_table "test_table", [{:name => :test_col, :type => :string }]
      first_column = @table.describe.first
      assert_equal 'test_col', first_column[:name]
      assert_equal 'string', first_column[:type]
    end

    should "correct your table name to a certain degree on create" do
      @table = @ft.create_table "test table", [{:name => "test col", :type => "string" }]
      assert_equal "test_table", @table.name
    end

    should "correct column names to a certain degree on create" do
      table_name = "test_table"
      column_name = "test'col"
      @ft.create_table table_name, [{:name => column_name, :type => "string" }]
      @table = @ft.show_tables.select{|t| t.name == table_name}.first
      column_info = @table.describe
      column_with_right_name = column_info.select{|c| c[:name] == column_name }.first
      assert_equal column_name, column_with_right_name[:name]
    end

    should "return you a list of your fusion tables" do
      @table = @ft.create_table "test_table", [{:name => "test col", :type => "string" }]
      resp = @ft.show_tables
      assert resp.any? { |t| t.name == 'test_table' }
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
      assert_raise GData::Client::BadRequestError do
        assert_equal 0, @ft.drop(235243875629384756)
      end
    end
  end

end
