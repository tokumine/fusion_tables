fusion_tables
==============
<iframe style="float:right;" width="280px" height="150px" scrolling="no"  src="http://www.google.com/fusiontables/embedviz?viz=MAP&q=select+col0%2C+col1%2C+col2%2C+col3%2C+col4%2C+col5%2C+col6%2C+col7%2C+col8%2C+col9%2C+col10%2C+col11%2C+col12%2C+col13+from+245192+&h=false&lat=51.509383501611595&lng=-0.13586997985839844&z=12&t=4&l=col11"></iframe>

This gem lets you easily interact with [Google Fusion Tables API](http://www.google.com/fusiontables/Home) from your Ruby application via a plain SQL interface, or an object orientated interface.

upgrading to current (v0.4)
--------------------------
Thanks to DerekEder's work, v0.4 supports the new Fusion Tables JSON API rather than the now defunct CSV API. This has introduced some small (but possibly breaking) changes:

1. Geometry is returned as GeoJSON rather than KML.
2. Null values are returned as empty strings (the FT API does this, so we're a bit stuck here).
3. You need to supply an api_key to use the service. You can get an API key from your Google API console. 

See the example below and tests for more.

Demo and examples
------------------

* Twitter [demo](http://tables.googlelabs.com/DataSource?snapid=73106) / [code](http://github.com/tokumine/fusion_tables/blob/master/examples/compare_tweets.rb) /
[blog](http://www.tokumine.com/2010/08/10/fusion-tables-gem/)
* Boris bike [demo](http://tables.googlelabs.com/DataSource?snapid=78314) / [code](http://github.com/tokumine/fusion_tables/blob/master/examples/boris_bikes.rb) 
* [Tests](http://github.com/tokumine/fusion_tables/tree/master/test/)


Installation
-------------

``` bash
gem install fusion_tables
```

**Gem Dependencies**

* gdata_19 >= 1.1.2

**Rubies**

* 1.8.7
* 1.9.2

Usage 
------
``` ruby
require 'fusion_tables'
	
	
# Connect to service	
@ft = GData::Client::FusionTables.new      
@ft.clientlogin(username, password) 
@ft.set_api_key(api_key) # obtained from the google api console


# 1. SQL interface
# =========================
@ft.execute "SHOW TABLES" 
@ft.execute "INSERT INTO #{my_table_id} (name, geo) VALUES ('tokyo', '35.6894 139.6917');"
@ft.execute "SELECT count() FROM #{my_table_id};"


# 2. ORM interface
# ========================
# Browse existing tables
@ft.show_tables
 # => [table_1, table_2] 

# Getting table id suitable for using with google maps (see more below)
table_1.id #=> 42342 (the table's google id)

# Count data
table_1.count #=> 1

# Select data
table_1.select 
 #=> data

# Select data with conditions
table_1.select "name", "WHERE x=n"
 #=> data

# Select ROWIDs
row_ids = table_1.select "ROWID"

# Drop tables
@ft.drop table_1.id                    # table id
@ft.drop [table_1.id, table_2.id]     # arrays of table ids
@ft.drop /yacht/                      # regex on table name

# Creating a table
cols = [{:name => "friend name",    :type => 'string' },
        {:name => "age",            :type => 'number' },
        {:name => "meeting time",   :type => 'datetime' },
        {:name => "where",          :type => 'location' }]

new_table = @ft.create_table "My upcoming meetings", cols

# Inserting rows (auto chunks every 500)
data = [{"friend name" 	=> "Eric Wimp", 
         "age"          => 25, 
         "meeting time" => Time.utc(2010,"aug",10,20,15,1),
         "where"        => "29 Acacia Road, Nuttytown"}]
new_table.insert data

# Currently FT API only supports single row UPDATE.
new_table.update 1, [{"friend name"	=> "Bananaman"}]

# Delete row
new_table.delete 1

# Delete all rows
new_table.truncate!
```


Known Issues
-------------

* The Google gdata_19 gem conflicts with the GData2 gem. Only current fix is to uninstall GData2.
* You have to make a table public before you can display it on a map. This can only be done via FT web interface. 


Note on Patches/Pull Requests
------------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. 



Contributors
-------------

Largely based on Tom Verbeure's [work for MTBGuru](http://code.google.com/p/mtbguru-fusiontables/)

* tokumine
* sikachu
* troy
* wynst
* sdball
* jmannau
* tomykaira
* fallanic
* derekeder
